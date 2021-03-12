  
FROM ghcr.io/linuxserver/baseimage-alpine:3.13 AS buildstage

ENV JAGER_TRACING 0.7.0

RUN apk add --no-cache --virtual .build-deps \
  gcc \
  libc-dev \
  make \
  openssl-dev \
  pcre-dev \
  zlib-dev \
  linux-headers \
  curl \
  gnupg \
  libxslt-dev \
  gd-dev \
  geoip-dev \
  g++ \
  git \
  cmake \
  apache2-utils \
  git \
  libressl3.1-libssl \
  logrotate \
  nano \
  nginx

RUN wget "https://github.com/jaegertracing/jaeger-client-cpp/archive/v${JAGER_TRACING}.tar.gz" -O jaeger-tracing.tar.gz && \
    mkdir -p jaeger-tracing && \
    tar zxvf jaeger-tracing.tar.gz -C ./jaeger-tracing/ --strip-components=1 && \
    cd jaeger-tracing \
    && mkdir .build && cd .build \
    && cmake -DCMAKE_BUILD_TYPE=Release \
             -DBUILD_TESTING=OFF \
             -DJAEGERTRACING_WITH_YAML_CPP=ON .. \
    && make && make install \
    && export HUNTER_INSTALL_DIR=$(cat _3rdParty/Hunter/install-root-dir) \
    && cp /usr/local/lib64/libjaegertracing.so /usr/local/lib/libjaegertracing_plugin.so
    
FROM scratch

COPY --from=buildstage /usr/local/lib/ /libjaegertracing/
