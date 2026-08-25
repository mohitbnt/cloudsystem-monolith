#!/usr/bin/env bash
set -Eeuo pipefail

WORDPRESS_ROOT="/var/www/cloudsystem"
WP_CONFIG_TEMPLATE="${WORDPRESS_ROOT}/wp-config.php.template"
WP_CONFIG="${WORDPRESS_ROOT}/wp-config.php"

PHP_FPM_SERVICE="php8.3-fpm"

DB_SECRET_ARN="${db_secret_arn}"
S3_PARAMETER="${s3_parameter}"
REDIS_PARAMETER="${redis_parameter}"
AWS_REGION="${region}"

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

command -v aws >/dev/null 2>&1 || fail "AWS CLI is not installed."
command -v jq >/dev/null 2>&1 || fail "jq is not installed."
command -v wp >/dev/null 2>&1 || fail "WP-CLI is not installed."

export AWS_DEFAULT_REGION="$AWS_REGION"

log "Fetching MariaDB credentials from Secrets Manager"

SECRET_JSON="$(aws secretsmanager get-secret-value \
    --secret-id "$DB_SECRET_ARN" \
    --query SecretString \
    --output text)"

[[ -n "$SECRET_JSON" ]] || fail "MariaDB secret returned empty SecretString."

DB_HOST="$(jq -r '.host // empty' <<< "$SECRET_JSON")"
DB_PORT="$(jq -r '.port // 3306' <<< "$SECRET_JSON")"
DB_NAME="$(jq -r '.database // empty' <<< "$SECRET_JSON")"
DB_USER="$(jq -r '.username // empty' <<< "$SECRET_JSON")"
DB_PASSWORD="$(jq -r '.password // empty' <<< "$SECRET_JSON")"

[[ -n "$DB_HOST" ]] || fail "DB host missing from secret."
[[ -n "$DB_NAME" ]] || fail "DB database missing from secret."
[[ -n "$DB_USER" ]] || fail "DB username missing from secret."
[[ -n "$DB_PASSWORD" ]] || fail "DB password missing from secret."

log "Fetching S3 bucket from Parameter Store"

S3_BUCKET="$(aws ssm get-parameter \
    --name "$S3_PARAMETER" \
    --query Parameter.Value \
    --output text)"

[[ -n "$S3_BUCKET" ]] || fail "S3 bucket parameter returned an empty value."

log "Fetching Redis endpoint from Parameter Store"

REDIS_HOST="$(aws ssm get-parameter \
    --name "$REDIS_PARAMETER" \
    --query Parameter.Value \
    --output text)"

[[ -n "$REDIS_HOST" ]] || fail "Redis endpoint parameter returned an empty value."


log "Generating wp-config.php"

# The Golden AMI contains wp-config.php.template.
# Create a fresh runtime configuration from the template.
rm -f "$WP_CONFIG"
cp "$WP_CONFIG_TEMPLATE" "$WP_CONFIG"

log "Injecting runtime configuration"

sed -i \
    -e "s|CHANGE_ME_DB_NAME|$DB_NAME|g" \
    -e "s|CHANGE_ME_DB_USER|$DB_USER|g" \
    -e "s|CHANGE_ME_DB_PASSWORD|$DB_PASSWORD|g" \
    -e "s|CHANGE_ME_DB_HOST|${DB_HOST}:${DB_PORT}|g" \
    -e "s|CHANGE_ME_BUCKET_NAME|$S3_BUCKET|g" \
    -e "s|CHANGE_ME_REDIS_HOST|$REDIS_HOST|g" \
    "$WP_CONFIG"

log "Validating wp-config.php"

if grep -q 'CHANGE_ME_' "$WP_CONFIG"; then
    echo "Unresolved configuration values:"
    grep -n 'CHANGE_ME_' "$WP_CONFIG" || true
    fail "wp-config.php contains unresolved CHANGE_ME_ values."
fi

log "Setting config file permissions"

chown -R www-data:www-data "$WP_CONFIG"
chmod 644 "$WP_CONFIG"

log "Restarting application services"

systemctl restart "$PHP_FPM_SERVICE"
systemctl restart nginx

systemctl is-active --quiet "$PHP_FPM_SERVICE" || \
    fail "PHP-FPM failed after restart."

systemctl is-active --quiet nginx || \
    fail "Nginx failed after restart."

log "Runtime bootstrap completed"

echo "WordPress root : $WORDPRESS_ROOT"
echo "DB host        : $DB_HOST"
echo "DB port        : $DB_PORT"
echo "DB name        : $DB_NAME"
echo "Redis host     : $REDIS_HOST"
echo "S3 bucket      : $S3_BUCKET"
echo "AWS region     : $AWS_REGION"
echo
echo "Database initialization/import was NOT performed."

unset SECRET_JSON DB_PASSWORD DB_USER DB_NAME DB_HOST DB_PORT
unset S3_BUCKET REDIS_HOST