FROM debian:bookworm-slim

ARG TARGETARCH
ENV GOSU_VERSION="1.17"
ENV PATH="${PATH}:/opt/ts3server"
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/lib/"
ENV TEAMSPEAK_CHECKSUM=775a5731a9809801e4c8f9066cd9bc562a1b368553139c1249f2a0740d50041e
ENV TEAMSPEAK_URL=https://files.teamspeak-services.com/releases/server/3.13.7/teamspeak3-server_linux_amd64-3.13.7.tar.bz2

ENV TZ=Asia/Seoul
ENV LC_ALL=ko_KR.UTF-8
ENV LANG=ko_KR.UTF-8
ENV LANGUAGE=ko_KR:ko

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    bzip2 \
    ca-certificates \
    locales \
    libpipeline1 \
    lsb-base \
    tini \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i -e 's/# ko_KR.UTF-8 UTF-8/ko_KR.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen

RUN case "$TARGETARCH" in \
        "arm64") dpkg --add-architecture amd64; \
                apt-get update && apt-get install -y --no-install-recommends \
                binfmt-support \
                libc6:amd64 \
                libstdc++6:amd64 \
                qemu-user-static ;; \
        "amd64") apt-get update && apt-get install -y --no-install-recommends ;; \
    esac \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    addgroup --gid 1001 ts3server; \
    adduser -u 1001 --no-create-home --home /var/ts3server --ingroup ts3server --shell /usr/sbin/nologin --disabled-password ts3server; \
    install -d -o ts3server -g ts3server -m 775 /var/ts3server /var/run/ts3server /opt/ts3server

RUN set -eux; \
    # save list of currently installed packages for later so we can clean up
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates gnupg wget; \
    rm -rf /var/lib/apt/lists/*; \
    \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
    \
    # verify the signature
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    gpgconf --kill all; \
    rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
    \
    # clean up fetch dependencies
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    \
    chmod +x /usr/local/bin/gosu; \
    # verify that the binary works
    gosu --version; \
    gosu nobody true

RUN set -eux; \
    wget "${TEAMSPEAK_URL}" -O server.tar.bz2; \
    echo "${TEAMSPEAK_CHECKSUM} *server.tar.bz2" | sha256sum -c -; \
    mkdir -p /opt/ts3server; \
    tar -xf server.tar.bz2 --strip-components=1 -C /opt/ts3server; \
    rm server.tar.bz2; \
    cp /opt/ts3server/*.so /opt/ts3server/redist/* /usr/local/lib; \
    ldconfig /usr/local/lib

VOLUME /var/ts3server/
WORKDIR /var/ts3server/

EXPOSE 9987/udp 10011/tcp 30033/tcp

COPY entrypoint.sh /opt/ts3server

ENTRYPOINT [ "tini", "--", "entrypoint.sh" ]
CMD [ "ts3server" ]
