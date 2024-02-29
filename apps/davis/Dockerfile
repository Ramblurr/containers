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

# Davis installation
RUN mkdir /var/www/davis \
  && apk add --no-cache --virtual=.build-deps git composer \
  && apk add --no-cache php82-ctype php82-gd php82-tokenizer php82-dom php82-xml phpunit php82-simplexml php82-xmlreader php82-session \
  && git clone https://github.com/tchapi/davis /var/www/davis \
  && cd /var/www/davis \
  && git reset --hard ${VERSION} \
  && composer update --no-interaction --with-all-dependencies \
  && APP_ENV=prod COMPOSER_ALLOW_SUPERUSER=1 composer install --no-ansi --no-dev --no-interaction --no-progress --optimize-autoloader \
  && chown -R root:root /var/www/davis \
  && chmod -R 755 /var/www/davis \
  && apk del --purge .build-deps \
  && docker-php-source delete

WORKDIR /var/www/davis

# rootless nginx
RUN apk add --no-cache nginx nginx-mod-http-lua tzdata

COPY ./vhost.conf /etc/nginx/http.d/default.conf
COPY ./nginx.conf /etc/nginx/nginx.conf

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && mkdir -p /var/lib/nginx/logs \
    && ln -sf /dev/stderr /var/lib/nginx/logs/error.log \
    && ln -sf /dev/stdout /var/lib/nginx/logs/access.log \
    && chmod 755 /var/lib/nginx /etc/nginx

COPY ./davis-entrypoint.sh /davis-entrypoint.sh

ENTRYPOINT ["/davis-entrypoint.sh"]

ENV DATABASE_DRIVER=sqlite
ENV DATABASE_URL=sqlite:////tmp/davis-database.db
ENV APP_ENV=prod
ENV DAVIS_SERVER_NAME=changeme.com
ENV DAVIS_UPSTREAM=127.0.0.1:9000
