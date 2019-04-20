FROM alpine

ENV PASSWD="passwd" VER="3.2.5" IP="0.0.0.0" PORT="80"

RUN apk upgrade --update \
    && apk add bash libsodium \
    && apk add --virtual .build-deps \
        autoconf \
        automake \
        xmlto \
        build-base \
        curl \
        c-ares-dev \
        libev-dev \
        libtool \
        linux-headers \
        udns-dev \
        libsodium-dev \
        mbedtls-dev \
        pcre-dev \
        udns-dev \
        tar \
        git \
    && curl -sSLO https://github.com/shadowsocks/shadowsocks-libev/releases/download/v${VER}/shadowsocks-libev-${VER}.tar.gz \
    && tar -zxf shadowsocks-libev-${VER}.tar.gz \
    && (cd shadowsocks-libev-${VER} \
    && ./configure --prefix=/usr --disable-documentation \
    && make install) \
    && git clone https://github.com/shadowsocks/simple-obfs.git \
    && (cd simple-obfs \
    && git submodule update --init --recursive \
    && ./autogen.sh && ./configure --disable-documentation\
    && make && make install) \
    && runDeps="$( \
        scanelf --needed --nobanner /usr/bin/ss-* /usr/local/bin/obfs-* \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | xargs -r apk info --installed \
            | sort -u \
        )" \
    && apk add --virtual .run-deps $runDeps \
    && apk del .build-deps \
    && rm -rf shadowsocks-libev-${VER}.tar.gz \
        shadowsocks-libev-${VER} \
        simple-obfs \
        /var/cache/apk/*

ADD entrypoint.sh /entrypoint.sh
ADD config.json /etc/config.json
RUN chmod +x /entrypoint.sh 

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
