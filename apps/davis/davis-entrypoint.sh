#!/bin/sh
if [ "$1" = "nginx" ]; then
    echo "Starting Nginx..."
    exec nginx -g 'daemon off;'
else
    echo "Starting davis PHP-FPM..."
    exec php-fpm
fi

