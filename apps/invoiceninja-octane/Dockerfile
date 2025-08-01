ARG VERSION
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT=""
ARG TARGETPLATFORM
ARG PHP_VERSION=8.4
ARG FRANKENPHP_VERSION=1
ARG DEBIAN_VERSION=bookworm

FROM docker.io/dunglas/frankenphp:${FRANKENPHP_VERSION}-php${PHP_VERSION}-${DEBIAN_VERSION} AS prepare-app

ARG VERSION

RUN if [ "${VERSION}" = "latest" ]; then \
        url="https://github.com/invoiceninja/invoiceninja/releases/latest/download/invoiceninja.tar.gz"; \
    else \
        url="https://github.com/invoiceninja/invoiceninja/releases/download/${VERSION}/invoiceninja.tar.gz"; \
    fi \
    && curl -sL "${url}" | \
    tar -xz \
    && ln -s ./resources/views/react/index.blade.php ./public/index.html \
    # Symlink
    && php artisan storage:link \
    # Octane
    && php artisan octane:install --server=frankenphp

# ==================
# InvoiceNinja image
# ==================
FROM docker.io/dunglas/frankenphp:${FRANKENPHP_VERSION}-php${PHP_VERSION}-${DEBIAN_VERSION}

ARG user=ninja
ARG cuid=3015
ARG cgid=3015

# PHP modules
ARG php_require="bcmath gd mbstring pdo_mysql zip"
ARG php_suggest="exif imagick intl pcntl soap saxon-12.5.0"
ARG php_extra="opcache"

RUN groupadd -r -g ${cgid} ${user} && \
    useradd -r -u ${cuid} -g ${cgid} ${user}

# Allow to bind to privileged ports
RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/frankenphp

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    mariadb-client \
    # Unicode support for PDF
    fonts-noto-cjk-extra \
    fonts-wqy-microhei \
    fonts-wqy-zenhei \
    xfonts-wqy \
    # Create config directory for chromium
    && mkdir /config/chromium \
    && chown ${user}: /config/chromium \
    # Cleanup
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN install-php-extensions \
    ${php_require} \
    ${php_suggest} \
    ${php_extra}

# Configure PHP
RUN ln -s "${PHP_INI_DIR}/php.ini-production" "${PHP_INI_DIR}/php.ini"

COPY defaults/php/php.ini /usr/local/etc/php/conf.d/invoiceninja.ini

# Create directory for artisan tinker (init.sh)
RUN mkdir /config/psysh \
    && chown ${user}: /config/psysh

# Change owner for caddy directories
RUN chown -R ${user}: \
    /data/caddy \
    /config/caddy

# InvoiceNinja
COPY --from=prepare-app --chown=${user}:${user} /app /app

# Add initialization script
COPY --chmod=0755 defaults/scripts/init.sh /usr/local/bin/init.sh

USER ${user}

ENV FILESYSTEM_DISK=debian_docker
ENV IS_DOCKER=true
ENV SNAPPDF_CHROMIUM_PATH=/usr/bin/chromium
ENV APP_ENV=production

# Add healthchecks
HEALTHCHECK --start-period=10s CMD \
    if [ "$LARAVEL_ROLE" = "worker" ]; then \
        pgrep -f queue:work; \
    elif [ "$LARAVEL_ROLE" = "scheduler" ]; then \
        pgrep -f schedule:work; \
    else \
        pgrep -f octane:frankenphp; \
    fi

ENTRYPOINT ["/usr/local/bin/init.sh"]
CMD ["app"]
