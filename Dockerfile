ARG grafana_version=10.0.2
ARG grafana_image=grafana-oss:10.0.2-ubuntu


FROM grafana/${grafana_image}:${grafana_version}

# Make it as simple as possible to access the grafana instance for development purposes
# Do NOT enable these settings in a public facing / production grafana instance
ENV GF_AUTH_ANONYMOUS_ORG_ROLE "Admin"
ENV GF_AUTH_ANONYMOUS_ENABLED "true"
ENV GF_AUTH_BASIC_ENABLED "false"

# Set development mode so plugins can be loaded without the need to sign
# ENV GF_DEFAULT_APP_MODE "development"

# Установка необходимых пакетов для сборки glibc
RUN apt-get update && apt-get install -y \
    wget \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Загрузка и установка glibc 2.38
RUN mkdir /glibc && cd /glibc \
    && wget http://ftp.gnu.org/gnu/libc/glibc-2.38.tar.gz \
    && tar -xvzf glibc-2.38.tar.gz \
    && cd glibc-2.38 \
    && mkdir build \
    && cd build \
    && ../configure \
    && make -j4 \
    && make install

# Inject livereload script into grafana index.html
USER root
RUN sed -i 's/<\/body><\/html>/<script src=\"http:\/\/localhost:35729\/livereload.js\"><\/script><\/body><\/html>/g' /usr/share/grafana/public/views/index.html
