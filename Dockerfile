FROM docker.io/library/ubuntu:jammy

ARG TARGETARCH

LABEL org.opencontainers.image.authors="https://bitnami.com/contact; https://sidlibrary.org" \
      org.opencontainers.image.description="Application packaged by Bitnami; flavoured by Sidney Jeong" \
      org.opencontainers.image.ref.name="7.5.1-jammy-r0" \
      org.opencontainers.image.source="https://github.com/sid0831/mattermost-container" \
      org.opencontainers.image.title="mattermost" \
      org.opencontainers.image.vendor="VMware, Inc.; Sidney Jeong" \
      org.opencontainers.image.version="7.5.1"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="ubuntu-22.04" \
    OS_NAME="linux"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN apt-get update && install_packages software-properties-common apt-transport-https apt-utils ca-certificates acl gnupg curl lsb-release ubuntu-keyring && \
    install_packages libcrypt1 libgeoip1 libpcre3 libssl3 procps zlib1g gosu git && \
    curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor > /usr/share/keyrings/nginx-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/ubuntu \
    $(lsb_release -cs) nginx" > /etc/apt/sources.list.d/nginx.list && \
    apt-get update && apt-get -y install nginx
RUN apt-get update && apt-get --autoremove full-upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives
RUN mkdir -p /opt/bitnami/nginx/logs /opt/bitnami/nginx/html /opt/bitnami/nginx/tmp /opt/bitnami/nginx/sbin /opt/bitnami/nginx/server_blocks && \
    cp -av /etc/nginx /opt/bitnami/nginx/conf && \
    git clone --single-branch --branch maintenance-page https://github.com/sid0831/sid0831.github.io /opt/bitnami/nginx/html && \
    ln -sf /dev/stdout /opt/bitnami/nginx/logs/access.log && ln -sf /dev/stderr /opt/bitnami/nginx/logs/error.log
RUN mkdir -p /opt/bitnami/mattermost/data && \
    curl -fsSL https://releases.mattermost.com/7.5.1/mattermost-7.5.1-linux-amd64.tar.gz | \
    tar -zxf - --strip-components=1 --no-same-owner -C /opt/bitnami/mattermost && \
    chmod -R g+rwX /opt/bitnami && mv /opt/bitnami/mattermost/config/config.json /opt/bitnami/mattermost/data/config.json && \
    ln -sfr /opt/bitnami/mattermost/data/config.json /opt/bitnami/mattermost/config/config.json

COPY rootfs /
RUN cp -av /usr/sbin/nginx /opt/bitnami/nginx/sbin/nginx && \
    chown -R 1001:1001 /opt/bitnami && chmod -R g+rwX /opt/bitnami
RUN /opt/bitnami/scripts/nginx/postunpack.sh
ENV APP_VERSION="7.5.1" \
    BITNAMI_APP_NAME="nginx" \
    NGINX_HTTPS_PORT_NUMBER="" \
    NGINX_HTTP_PORT_NUMBER="" \
    PATH="/opt/bitnami/common/bin:/opt/bitnami/nginx/sbin:$PATH"

EXPOSE 8065 8080 8443

WORKDIR /opt/bitnami/mattermost
USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/mattermost/run.sh" ]
# ENTRYPOINT [ "/opt/bitnami/scripts/nginx/entrypoint.sh" ]
# CMD [ "/opt/bitnami/scripts/nginx/run.sh" ]
