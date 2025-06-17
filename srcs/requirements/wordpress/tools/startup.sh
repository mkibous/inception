#!/bin/bash
set -e
WORDPRESS_DB_HOST=$(cat /run/secrets/DB_HOST)
WORDPRESS_DB_USER=$(cat /run/secrets/DB_USER)
WORDPRESS_DB_PASSWORD=$(cat /run/secrets/DB_PASSWORD)
WORDPRESS_DB_NAME=$(cat /run/secrets/DB_NAME)
ADMIN_PASSWORD=$(cat /run/secrets/ADMIN_PASSWORD)
ADMIN_USER=$(cat /run/secrets/ADMIN_USER)
ADMIN_EMAIL=$(cat /run/secrets/ADMIN_EMAIL)
WORDPRESS_USER_NAME=$(cat /run/secrets/WORDPRESS_USER_NAME)
WORDPRESS_USER_PASSWORD=$(cat /run/secrets/WORDPRESS_USER_PASSWORD)
WORDPRESS_USER_EMAIL=$(cat /run/secrets/WORDPRESS_USER_EMAIL)
sleep 5
mkdir -p /run/php
chown -R www-data:www-data /run/php

sed -i 's|listen = /run/php/php7.4-fpm.sock|listen = 0.0.0.0:9000|' /etc/php/7.4/fpm/pool.d/www.conf



if mariadb -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ MariaDB is ready."
else
    echo "❌ MariaDB not ready. Waiting 2 seconds before exit..."
    sleep 2
    exit 1
fi
if [ ! -f /var/www/html/wp-config.php ]; then
  echo "🛠️ Setting up wp-config.php..."
  if [ ! -f /var/www/html/wp-config-sample.php ]; then
  echo "⬇️ Downloading WordPress..."
  wp core download --path=/var/www/html --allow-root
fi
  cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

  sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" /var/www/html/wp-config.php
  sed -i "s/username_here/${WORDPRESS_DB_USER}/" /var/www/html/wp-config.php
  sed -i "s/password_here/${WORDPRESS_DB_PASSWORD}/" /var/www/html/wp-config.php
  sed -i "s/localhost/${WORDPRESS_DB_HOST}/" /var/www/html/wp-config.php
fi

if ! wp user list --role=administrator --field=user_login --allow-root --path=/var/www/html | grep -q . > /dev/null 2>&1; then
  echo "👤 Creating admin user..."
  if ! wp core is-installed --allow-root; then
    wp core install \
    --url="https://$DOMAIN_NAME" \
    --path="/var/www/html" \
    --title="My Site" \
    --admin_user="$ADMIN_USER" \
    --admin_password="$ADMIN_PASSWORD" \
    --admin_email="$ADMIN_EMAIL" \
    --allow-root
  else
    echo "WordPress is already installed."
    wp user create $ADMIN_USER $ADMIN_EMAIL \
    --role=administrator \
    --user_pass="$ADMIN_PASSWORD" \
    --allow-root \
    --path=/var/www/html
  fi

fi
# check if the user already exists
if ! wp user get $WORDPRESS_USER_NAME --allow-root --path=/var/www/html > /dev/null 2>&1; then
  echo "👤 Creating user..."
  wp user create $WORDPRESS_USER_NAME  $WORDPRESS_USER_EMAIL \
  --role=author \
  --user_pass="$WORDPRESS_USER_PASSWORD" \
  --allow-root \
  --path=/var/www/html
fi
wp config set WP_CACHE true --type=constant --allow-root --path=/var/www/html
wp config set WP_REDIS_HOST redis --type=constant --allow-root --path=/var/www/html
wp config set WP_REDIS_PORT 6379 --type=constant --allow-root --path=/var/www/html
wp config set WP_CACHE_KEY_SALT localhost: --type=constant --allow-root --path=/var/www/html #to avoid key conflicts Without a unique salt
#wp config set ... --type=constant define const
# Install Redis plugin if not already installed
if ! wp plugin is-installed redis-cache --allow-root --path=/var/www/html; then
  echo "📦 Installing Redis Cache plugin..."
  wp plugin install redis-cache --activate --allow-root --path=/var/www/html
else
  wp plugin activate redis-cache --allow-root --path=/var/www/html
fi

# # Enable Redis object cache
wp redis enable --allow-root --path=/var/www/html


echo "🚀 Démarrage de PHP-FPM..."
exec php-fpm7.4 --nodaemonize