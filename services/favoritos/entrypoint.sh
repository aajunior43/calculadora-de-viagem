#!/bin/sh
set -eu

mkdir -p /var/www/html/data
if [ ! -f /var/www/html/data/favorites.txt ]; then
    cp /var/www/html/favorites.txt /var/www/html/data/favorites.txt
fi
chown -R www-data:www-data /var/www/html/data

exec docker-php-entrypoint "$@"

