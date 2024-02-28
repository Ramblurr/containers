#!/bin/sh
if [ "$1" = "nginx" ]; then
    echo "Starting Nginx..."
    exec nginx -g 'daemon off;'
else
    echo "Starting davis PHP-FPM..."
    cd /var/www/davis
    ./bin/console doctrine:migrations:migrate --no-interaction
    exec php-fpm
fi

