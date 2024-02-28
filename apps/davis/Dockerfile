ARG VERSION
FROM ghcr.io/tchapi/davis:v${VERSION} as upstream

ARG TARGETPLATFORM
ARG TARGETARCH
ARG TARGETOS

LABEL dev.bjw-s.image.target_platform=$TARGETPLATFORM
LABEL dev.bjw-s.image.target_architecture=$TARGETARCH
LABEL dev.bjw-s.image.target_os=$TARGETOS
LABEL org.opencontainers.image.source="https://github.com/tchapi/davis"

FROM docker.io/nginxinc/nginx-unprivileged:1-alpine
COPY --from=upstream --chown=nginx:nginx /var/www/davis /var/www/davis
COPY ./nginx.conf /etc/nginx/conf.d/default.conf
