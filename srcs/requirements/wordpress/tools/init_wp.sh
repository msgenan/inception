#!/bin/bash
set -e
set -o pipefail

DB_PASSWORD=$(cat /run/secrets/db_password | tr -d '\r')
WP_ADMIN_PASSWORD=$(grep WP_ADMIN_PASSWORD /run/secrets/credentials | cut -d '=' -f2- | tr -d '\r')
WP_USER_PASSWORD=$(grep WP_USER_PASSWORD /run/secrets/credentials | cut -d '=' -f2- | tr -d '\r')

if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "First run: installing WordPress..."

    wp core download --force --allow-root

    wp config create \
        --force \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost=mariadb \
        --allow-root

    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root

    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --allow-root

    echo "WordPress installation complete."
else
    echo "WordPress already installed, skipping."
fi

chown -R www-data:www-data /var/www/html

exec php-fpm8.2 -F
