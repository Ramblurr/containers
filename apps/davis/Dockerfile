ARG VERSION
ARG fpm_user=2000:2000
FROM ghcr.io/tchapi/davis:v${VERSION}
ARG TARGETPLATFORM
ARG TARGETARCH
ARG TARGETOS

LABEL dev.bjw-s.image.target_platform=$TARGETPLATFORM
LABEL dev.bjw-s.image.target_architecture=$TARGETARCH
LABEL dev.bjw-s.image.target_os=$TARGETOS
LABEL org.opencontainers.image.source="https://github.com/tchapi/davis"

USER root
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

COPY ./davis-entrypoint.sh /davis-entrypoint.sh

#RUN chown -R ${FPM_USER} /var/www/davis
#USER $FPM_USER
ENTRYPOINT ["/davis-entrypoint.sh"]
