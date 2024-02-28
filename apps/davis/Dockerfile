FROM php:8.2-fpm-alpine

# https://github.com/docker-library/php/blob/master/8.2/alpine3.18/fpm/Dockerfile#L33
ARG fpm_user=82:82
ARG TARGETPLATFORM
ARG TARGETARCH
ARG TARGETOS
ENV FPM_USER=${fpm_user}

LABEL org.opencontainers.image.authors="github.com/ramblurr"
LABEL org.opencontainers.image.url="https://github.com/ramblurr/containers"
LABEL org.opencontainers.image.description="A simple, fully translatable admin interface for sabre/dav based on Symfony 5 and Bootstrap 4"
LABEL dev.bjw-s.image.target_platform=$TARGETPLATFORM
LABEL dev.bjw-s.image.target_architecture=$TARGETARCH
LABEL dev.bjw-s.image.target_os=$TARGETOS
LABEL org.opencontainers.image.source="https://github.com/tchapi/davis"

# Run update, and gets basic packages and packages for runtime
RUN apk --no-progress --update add --no-cache \
        curl unzip fcgi \
        # These are for php-intl
        icu-libs \
        # This one is for IMAP (to provide libc-client.so)
        c-client \
        # This one for LDAP
        libldap \
        # These are for GD (map image in mail)
        freetype \
        libjpeg-turbo \
        libpng \
        # This is for PostgreSQL
        libpq

# Intl support
RUN apk --update --virtual build-deps-intl add --no-cache icu-dev \
    && docker-php-ext-install intl \
    && apk del build-deps-intl \
    && rm -rf /tmp/*

# PDO: MySQL
RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-install pdo_mysql

# PDO: PostgreSQL
RUN apk --update --virtual build-deps-pg add --no-cache libpq-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pgsql pdo_pgsql \
    && apk del build-deps-pg \
    && rm -rf /tmp/*

# GD (map image in mail)
RUN apk --update --virtual build-deps-gd add --no-cache freetype-dev libjpeg-turbo-dev libpng-dev \
    && docker-php-ext-configure gd --with-freetype \
    && docker-php-ext-install gd \
    && docker-php-ext-enable gd \
    && apk del build-deps-gd \
    && rm -rf /tmp/*

# LDAP auth support
RUN apk --update --virtual build-deps-ldap add --no-cache openldap-dev \
    && docker-php-ext-configure ldap \
    && docker-php-ext-install ldap \
    && apk del build-deps-ldap \
    && rm -rf /tmp/*

# IMAP auth support
RUN apk --update --virtual build-deps-imap add --no-cache imap-dev openssl-dev krb5-dev \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap \
    && apk del build-deps-imap \
    && rm -rf /tmp/*

# rootless nginx
RUN apk add --no-cache nginx && \
    apk add --no-cache tzdata

ADD ./nginx.conf /etc/nginx/http.d/default.conf

RUN    sed -i 's,listen       80;,listen       8080;,' /etc/nginx/http.d/default.conf \
    && sed -i 's,user nginx;,pid /tmp/nginx.pid;,' /etc/nginx/nginx.conf \
    && sed -i "/^http {/a \    proxy_temp_path /tmp/proxy_temp;\n    client_body_temp_path /tmp/client_temp;\n    fastcgi_temp_path /tmp/fastcgi_temp;\n    uwsgi_temp_path /tmp/uwsgi_temp;\n    scgi_temp_path /tmp/scgi_temp;\n" /etc/nginx/nginx.conf \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && mkdir -p /var/lib/nginx/logs \
    && ln -sf /dev/stderr /var/lib/nginx/logs/error.log \
    && ln -sf /dev/stdout /var/lib/nginx/logs/access.log \
    && chmod 755 /var/lib/nginx /etc/nginx

# Davis installation
RUN mkdir /var/www/davis \
  && apk add --no-cache --virtual=.build-deps git \
  && git clone https://github.com/tchapi/davis /var/www/davis \
  && apk del --purge .build-deps \
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && cd /var/www/davis \
  && APP_ENV=prod COMPOSER_ALLOW_SUPERUSER=1 composer install --no-ansi --no-dev --no-interaction --no-progress --optimize-autoloader \
  && chown -R root:root /var/www/davis \
  && chmod -R 755 /var/www/davis

WORKDIR /var/www/davis

# PHP-FPM healthcheck
RUN set -xe && echo "pm.status_path = /status" >> /usr/local/etc/php-fpm.d/zz-docker.conf
RUN curl https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/v0.5.0/php-fpm-healthcheck \
    -o /usr/local/bin/php-fpm-healthcheck -s \
    && chmod +x /usr/local/bin/php-fpm-healthcheck

# Cleanup (only useful when using --squash)
RUN docker-php-source delete
RUN rm -rf /usr/local/bin/composer

HEALTHCHECK --interval=30s --timeout=1s CMD php-fpm-healthcheck || exit 1


COPY ./davis-entrypoint.sh /davis-entrypoint.sh

ENTRYPOINT ["/davis-entrypoint.sh"]

ENV DATABASE_DRIVER=sqlite
ENV DATABASE_URL=sqlite:////tmp/davis-database.db
ENV APP_ENV=prod
