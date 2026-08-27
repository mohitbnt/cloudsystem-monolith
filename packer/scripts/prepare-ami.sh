#!/usr/bin/env bash
set -Eeuo pipefail

WORDPRESS_ROOT="/var/www/cloudsystem"
PHP_VERSION="8.3"
PHP_FPM_SERVICE="php${PHP_VERSION}-fpm"
PHP_FPM_POOL="cloudsystem"
PHP_FPM_SOCKET="/run/php/${PHP_FPM_POOL}.sock"

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

[[ "$EUID" -eq 0 ]] || fail "Run this script as root."

export DEBIAN_FRONTEND=noninteractive

log "Updating operating system"

apt-get update
apt-get upgrade -y

log "Installing Nginx, PHP-FPM and required PHP extensions and other dependencies"

apt-get install -y \
    nginx \
    unzip \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    jq \
    mariadb-client \
    gzip \
    software-properties-common \
    php${PHP_VERSION} \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-redis

log "Installing AWS CLI v2"

if ! command -v aws >/dev/null 2>&1; then
    tmpdir="$(mktemp -d)"
    curl -fsSL \
        https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip \
        -o "$tmpdir/awscliv2.zip"

    unzip -q "$tmpdir/awscliv2.zip" -d "$tmpdir"
    "$tmpdir/aws/install"
    rm -rf "$tmpdir"
fi

aws --version

log "Installing WP-CLI"

if ! command -v wp >/dev/null 2>&1; then
    curl -fsSL \
        https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
        -o /usr/local/bin/wp

    chmod +x /usr/local/bin/wp
fi

wp --info

log "Installing SSM Agent"

if ! snap list amazon-ssm-agent >/dev/null 2>&1; then
    snap install amazon-ssm-agent --classic
fi

systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service

log "Preparing WordPress application"

mkdir -p "$WORDPRESS_ROOT"

if [[ -n "${WORDPRESS_ARTIFACT:-}" ]]; then
    [[ -f "$WORDPRESS_ARTIFACT" ]] || \
        fail "WordPress artifact not found: $WORDPRESS_ARTIFACT"

    rm -rf /tmp/cloudsystem-wordpress-extract
    mkdir -p /tmp/cloudsystem-wordpress-extract

    tar -xzf "$WORDPRESS_ARTIFACT" \
        -C /tmp/cloudsystem-wordpress-extract

    [[ -f /tmp/cloudsystem-wordpress-extract/wp-settings.php ]] || \
        fail "Artifact does not contain a valid WordPress root."

    find "$WORDPRESS_ROOT" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
    cp -a /tmp/cloudsystem-wordpress-extract/. "$WORDPRESS_ROOT/"

    rm -rf /tmp/cloudsystem-wordpress-extract
else
    echo "WORDPRESS_ARTIFACT is not set; skipping WordPress extraction."
fi

mkdir -p "$WORDPRESS_ROOT/wp-content/uploads"

log "Configuring dedicated PHP-FPM pool"

# Remove the distribution default pool.
rm -f "/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"

cat > "/etc/php/${PHP_VERSION}/fpm/pool.d/${PHP_FPM_POOL}.conf" <<EOF
[${PHP_FPM_POOL}]
user = www-data
group = www-data

listen = ${PHP_FPM_SOCKET}
listen.owner = www-data
listen.group = www-data
listen.mode = 0660

pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3

pm.max_requests = 500
EOF

php-fpm${PHP_VERSION} -t

systemctl enable "$PHP_FPM_SERVICE"
systemctl restart "$PHP_FPM_SERVICE"

log "Configuring Nginx"

cat > /etc/nginx/sites-available/cloudsystem <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    root ${WORDPRESS_ROOT};
    index index.php index.html;

    client_max_body_size 64M;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:${PHP_FPM_SOCKET};
    }

    location ~* /(?:uploads|files)/.*\.php$ {
        deny all;
    }

    location ~ /\. {
        deny all;
    }
}
EOF

rm -f /etc/nginx/sites-enabled/default
ln -sfn \
    /etc/nginx/sites-available/cloudsystem \
    /etc/nginx/sites-enabled/cloudsystem

nginx -t
systemctl enable nginx
systemctl restart nginx

log "Setting WordPress permissions"

chown -R www-data:www-data "$WORDPRESS_ROOT"

find "$WORDPRESS_ROOT" -type d -exec chmod 755 {} +
find "$WORDPRESS_ROOT" -type f -exec chmod 644 {} +

# Runtime configuration is intentionally generated later.
rm -f "$WORDPRESS_ROOT/wp-config.php"

log "Validating required components"

php -m | grep -qi '^redis$' || fail "PHP Redis extension is not installed."

[[ -d "$WORDPRESS_ROOT/wp-content/plugins/redis-cache" ]] \
    && echo "Redis Object Cache plugin: present"

[[ -d "$WORDPRESS_ROOT/wp-content/plugins/amazon-s3-and-cloudfront" ]] \
    && echo "WP Offload Media plugin: present"

[[ -S "$PHP_FPM_SOCKET" ]] || \
    fail "PHP-FPM socket not found: $PHP_FPM_SOCKET"

log "Cleaning build-time state"

apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*

# Remove machine-specific SSH host keys; they are regenerated on first boot.
rm -f /etc/ssh/ssh_host_*

journalctl --rotate || true
journalctl --vacuum-time=1s || true

rm -f /root/.bash_history
rm -f /home/*/.bash_history 2>/dev/null || true

log "Final validation"

systemctl is-enabled nginx >/dev/null
systemctl is-active nginx >/dev/null

systemctl is-enabled "$PHP_FPM_SERVICE" >/dev/null
systemctl is-active "$PHP_FPM_SERVICE" >/dev/null

php-fpm${PHP_VERSION} -t
nginx -t

echo
echo "AMI preparation completed successfully."
echo
echo "WordPress root : $WORDPRESS_ROOT"
echo "PHP-FPM pool   : $PHP_FPM_POOL"
echo "PHP-FPM socket : $PHP_FPM_SOCKET"
echo "Nginx          : $(systemctl is-active nginx)"
echo "PHP-FPM        : $(systemctl is-active "$PHP_FPM_SERVICE")"
echo "AWS CLI        : $(aws --version 2>&1)"
echo "WP-CLI         : $(wp --info | awk -F': ' '/WP-CLI version/ {print $2}')"
echo