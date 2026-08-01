#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(grep WP_ADMIN_PASSWORD /run/secrets/credentials | cut -d '=' -f2)
WP_USER_PASSWORD=$(grep WP_USER_PASSWORD /run/secrets/credentials | cut -d '=' -f2)

until mariadb-admin ping -h mariadb -u"${MYSQL_USER}" -p"${DB_PASSWORD}" --silent 2>/dev/null; do
    echo "Waiting for database connection..."
    sleep 2
done

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "First run: installing WordPress..."

    wp core download --allow-root

    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost=mariadb \
        --allow-root

    wp config set WP_REDIS_HOST redis --allow-root

    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root

    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --allow-root

    wp plugin install redis-cache --activate --allow-root
    wp redis enable --allow-root

    echo "WordPress installation complete."
else
    echo "WordPress already installed, skipping."
fi

chown -R www-data:www-data /var/www/html

exec php-fpm8.2 -F
