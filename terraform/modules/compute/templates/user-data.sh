#!/usr/bin/env bash
set -Eeuo pipefail

WORDPRESS_ROOT="/var/www/cloudsystem"
WP_CONFIG_TEMPLATE="$${WORDPRESS_ROOT}/wp-config.php.template"
WP_CONFIG="$${WORDPRESS_ROOT}/wp-config.php"
PHP_FPM_SERVICE="php8.3-fpm"

DB_SECRET_ARN="${db_secret_arn}"
S3_PARAMETER="${s3_parameter}"
REDIS_PARAMETER="${redis_parameter}"
DB_BACKUP_BUCKET="${db_backup_bucket}"
DB_BACKUP_KEY="${db_backup_key}"
AWS_REGION="${region}"

DB_BACKUP_FILE="/tmp/cloudsystem-database.sql.gz"
DB_INIT_LOCK_NAME="cloudsystem-db-initialization"
DB_INIT_LOCK_TIMEOUT=5

exec > >(tee -a /var/log/cloudsystem-user-data.log | logger -t cloudsystem-user-data -s 2>/dev/console) 2>&1

log() {
    echo
    echo "============================================================"
    echo "$1"
    echo "============================================================"
}

fail() {
    echo "ERROR: $1" >&2
    exit 1
}

[[ "$EUID" -eq 0 ]] || fail "user-data must run as root."
[[ -d "$WORDPRESS_ROOT" ]] || fail "WordPress root not found: $WORDPRESS_ROOT"
[[ -f "$WP_CONFIG_TEMPLATE" ]] || fail "Missing $WP_CONFIG_TEMPLATE"

command -v aws >/dev/null 2>&1 || fail "AWS CLI is not installed."
command -v jq >/dev/null 2>&1 || fail "jq is not installed."
command -v mariadb >/dev/null 2>&1 || fail "MariaDB client is not installed."
command -v gzip >/dev/null 2>&1 || fail "gzip is not installed."

export AWS_DEFAULT_REGION="$AWS_REGION"

log "Fetching MariaDB credentials from Secrets Manager"

SECRET_JSON="$$(aws secretsmanager get-secret-value \
    --secret-id "$DB_SECRET_ARN" \
    --query SecretString \
    --output text)"

[[ -n "$SECRET_JSON" ]] || fail "MariaDB secret returned empty SecretString."

DB_HOST="$$(jq -r '.host // empty' <<< "$SECRET_JSON")"
DB_PORT="$$(jq -r '.port // 3306' <<< "$SECRET_JSON")"
DB_NAME="$$(jq -r '.database // empty' <<< "$SECRET_JSON")"
DB_USER="$$(jq -r '.username // empty' <<< "$SECRET_JSON")"
DB_PASSWORD="$$(jq -r '.password // empty' <<< "$SECRET_JSON")"

[[ -n "$DB_HOST" ]] || fail "DB host missing from secret."
[[ -n "$DB_NAME" ]] || fail "DB database missing from secret."
[[ -n "$DB_USER" ]] || fail "DB username missing from secret."
[[ -n "$DB_PASSWORD" ]] || fail "DB password missing from secret."

log "Fetching WordPress S3 bucket from Parameter Store"

S3_BUCKET="$$(aws ssm get-parameter \
    --name "$S3_PARAMETER" \
    --query Parameter.Value \
    --output text)"

[[ -n "$S3_BUCKET" ]] || fail "WordPress S3 bucket parameter returned empty."

log "Fetching Redis endpoint from Parameter Store"

REDIS_HOST="$$(aws ssm get-parameter \
    --name "$REDIS_PARAMETER" \
    --query Parameter.Value \
    --output text)"

[[ -n "$REDIS_HOST" ]] || fail "Redis endpoint parameter returned empty."

log "Generating wp-config.php"

rm -f "$WP_CONFIG"
cp "$WP_CONFIG_TEMPLATE" "$WP_CONFIG"

log "Injecting runtime configuration"

sed -i \
    -e "s|CHANGE_ME_DB_NAME|$DB_NAME|g" \
    -e "s|CHANGE_ME_DB_USER|$DB_USER|g" \
    -e "s|CHANGE_ME_DB_PASSWORD|$DB_PASSWORD|g" \
    -e "s|CHANGE_ME_DB_HOST|$${DB_HOST}:$${DB_PORT}|g" \
    -e "s|CHANGE_ME_BUCKET_NAME|$S3_BUCKET|g" \
    -e "s|CHANGE_ME_REDIS_HOST|$REDIS_HOST|g" \
    "$WP_CONFIG"

log "Validating wp-config.php"

if grep -q 'CHANGE_ME_' "$WP_CONFIG"; then
    grep -n 'CHANGE_ME_' "$WP_CONFIG" || true
    fail "wp-config.php contains unresolved CHANGE_ME_ values."
fi

log "Checking database initialization state"

export MYSQL_PWD="$DB_PASSWORD"

WP_OPTIONS_EXISTS="$$(
    mariadb \
        --host="$DB_HOST" \
        --port="$DB_PORT" \
        --user="$DB_USER" \
        "$DB_NAME" \
        -Nse "SELECT COUNT(*) FROM information_schema.tables
              WHERE table_schema='$${DB_NAME}'
              AND table_name='wp_options';"
)"

if [[ "$WP_OPTIONS_EXISTS" == "1" ]]; then
    log "Database is already initialized"
    echo "Database import skipped."

else
    log "Acquiring database initialization lock"

    LOCK_RESULT="$$(
        mariadb \
            --host="$DB_HOST" \
            --port="$DB_PORT" \
            --user="$DB_USER" \
            "$DB_NAME" \
            -Nse "SELECT GET_LOCK('$${DB_INIT_LOCK_NAME}', $${DB_INIT_LOCK_TIMEOUT});"
    )"

    if [[ "$LOCK_RESULT" != "1" ]]; then
        log "Another instance is initializing the database"
        echo "Database import skipped on this instance."

    else
        release_db_lock() {
            mariadb \
                --host="$DB_HOST" \
                --port="$DB_PORT" \
                --user="$DB_USER" \
                "$DB_NAME" \
                -Nse "SELECT RELEASE_LOCK('$${DB_INIT_LOCK_NAME}');" \
                >/dev/null 2>&1 || true
        }

        trap release_db_lock EXIT

        log "Rechecking database after acquiring lock"

        WP_OPTIONS_EXISTS="$$(
            mariadb \
                --host="$DB_HOST" \
                --port="$DB_PORT" \
                --user="$DB_USER" \
                "$DB_NAME" \
                -Nse "SELECT COUNT(*) FROM information_schema.tables
                      WHERE table_schema='$${DB_NAME}'
                      AND table_name='wp_options';"
        )"

        if [[ "$WP_OPTIONS_EXISTS" == "1" ]]; then
            log "Database was initialized by another instance"
        else
            log "Downloading database backup"

            aws s3 cp \
                "s3://$${DB_BACKUP_BUCKET}/$${DB_BACKUP_KEY}" \
                "$DB_BACKUP_FILE"

            [[ -s "$DB_BACKUP_FILE" ]] || \
                fail "Database backup is empty or was not downloaded."

            log "Importing database backup"

            gzip -dc "$DB_BACKUP_FILE" | \
                mariadb \
                    --host="$DB_HOST" \
                    --port="$DB_PORT" \
                    --user="$DB_USER" \
                    "$DB_NAME"

            log "Verifying database import"

            TABLE_COUNT="$$(
                mariadb \
                    --host="$DB_HOST" \
                    --port="$DB_PORT" \
                    --user="$DB_USER" \
                    "$DB_NAME" \
                    -Nse "SELECT COUNT(*)
                          FROM information_schema.tables
                          WHERE table_schema='$${DB_NAME}';"
            )"

            [[ "$TABLE_COUNT" -gt 0 ]] || \
                fail "Database import completed but no tables were found."

            SITEURL_EXISTS="$$(
                mariadb \
                    --host="$DB_HOST" \
                    --port="$DB_PORT" \
                    --user="$DB_USER" \
                    "$DB_NAME" \
                    -Nse "SELECT COUNT(*)
                          FROM wp_options
                          WHERE option_name='siteurl';"
            )"

            [[ "$SITEURL_EXISTS" == "1" ]] || \
                fail "wp_options/siteurl was not found after import."

            log "Database initialization completed successfully"
            echo "Imported tables: $TABLE_COUNT"
        fi
    fi
fi

rm -f "$DB_BACKUP_FILE"
unset MYSQL_PWD

log "Setting config file permissions"

chown -R www-data:www-data "$WORDPRESS_ROOT"
find "$WORDPRESS_ROOT" -type d -exec chmod 755 {} +
find "$WORDPRESS_ROOT" -type f -exec chmod 644 {} +

chmod 640 "$WP_CONFIG"
chown www-data:www-data "$WP_CONFIG"

log "Restarting application services"

systemctl restart "$PHP_FPM_SERVICE"
systemctl restart nginx

systemctl is-active --quiet "$PHP_FPM_SERVICE" || fail "PHP-FPM failed after restart."
systemctl is-active --quiet nginx || fail "Nginx failed after restart."

log "Runtime bootstrap completed"

echo "WordPress root      : $WORDPRESS_ROOT"
echo "DB host             : $DB_HOST"
echo "DB port             : $DB_PORT"
echo "DB name             : $DB_NAME"
echo "Redis host          : $REDIS_HOST"
echo "WordPress S3 bucket : $S3_BUCKET"
echo "DB backup bucket    : $DB_BACKUP_BUCKET"
echo "DB backup key       : $DB_BACKUP_KEY"
echo "AWS region          : $AWS_REGION"

unset SECRET_JSON DB_PASSWORD DB_USER DB_NAME DB_HOST DB_PORT
unset S3_BUCKET REDIS_HOST DB_BACKUP_BUCKET DB_BACKUP_KEY
