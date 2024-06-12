FROM docker.io/clojure:temurin-21-tools-deps-bookworm-slim
ARG TARGETOS
ARG TARGETOS
ARG TARGETPLATFORM
ARG TARGETARCH
ARG TARGETOS
ARG VERSION
ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    UMASK="0002" \
    TZ="Etc/UTC" \
    DEBIAN_FRONTEND=noninteractive
RUN set -e; \
    apt-get update; \
    apt-get install -y  curl unzip iputils-ping procps postgresql-client; \
    curl -s https://raw.githubusercontent.com/babashka/babashka/master/install | bash; \
    curl https://datomic-pro-downloads.s3.amazonaws.com/${VERSION}/datomic-pro-${VERSION}.zip -o /tmp/datomic-pro.zip; \
    unzip /tmp/datomic-pro.zip;  \
    mv datomic-pro-${VERSION} /opt/datomic-pro; \
    apt remove -y curl unzip; \
    rm -rf /var/lib/apt/lists/* /tmp/datomic-pro.zip

RUN set -e; \
    mkdir /config /data; \
    chmod 0776 /config /data; \
    printf "umask %d\n" "${UMASK}" > /etc/profile.d/umask.sh; \
    rm -rf /tmp/*;
VOLUME /config
VOLUME /data
COPY ./generate-properties.clj   /generate-properties.clj
COPY ./datomic-entrypoint.sh /datomic-entrypoint.sh
WORKDIR /opt/datomic-pro
ENTRYPOINT ["/datomic-entrypoint.sh"]
LABEL org.opencontainers.image.authors="github.com/ramblurr"
LABEL org.opencontainers.image.url="https://github.com/Ramblurr/containers/tree/main/apps/datomic-pro"
LABEL org.opencontainers.image.source="https://github.com/Ramblurr/containers"
LABEL org.opencontainers.image.description="Datomic Pro"
LABEL dev.bjw-s.image.target_platform=$TARGETPLATFORM
LABEL dev.bjw-s.image.target_architecture=$TARGETARCH
LABEL dev.bjw-s.image.target_os=$TARGETOS
ENV DATOMIC_TRANSACTOR_PROPERTIES_PATH /config/transactor.properties
