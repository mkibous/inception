#!/bin/bash
set -e
MARIADB_ROOT_PASSWORD=$(cat /run/secrets/DB_ROOT_PASSWORD)
MARIADB_DATABASE=$(cat /run/secrets/DB_NAME)
MARIADB_USER=$(cat /run/secrets/DB_USER)
MARIADB_PASSWORD=$(cat /run/secrets/DB_PASSWORD)
# Start MariaDB temporarily
echo "Starting MariaDB..."
mysqld_safe --datadir=/var/lib/mysql --bind-address=0.0.0.0 &
sleep 5

# Check if root has a password already
if mariadb -u root -e "SELECT 1;" > /dev/null 2>&1; then
    echo "Root has no password, setting it now..."
    mariadb -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';"
else
    echo "Root password already set, using it."
fi

# Use password for all further operations
echo "Creating database and users..."
mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;"
mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';"
mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';"
mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;" #reload db

echo "Stopping MariaDB..."
mysqladmin -u root -p"${MARIADB_ROOT_PASSWORD}" shutdown

echo "Starting MariaDB in foreground..."
exec mysqld_safe --datadir=/var/lib/mysql --bind-address=0.0.0.0 --port=3306
