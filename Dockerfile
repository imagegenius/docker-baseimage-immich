# syntax=docker/dockerfile:1

FROM ghcr.io/imagegenius/baseimage-ubuntu:mantic

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="ImageGenius Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="hydazz, martabal"

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    autoconf \
    bc \
    build-essential \
    cpanminus \
    g++ \
    git \
    libany-uri-escape-perl \
    libcapture-tiny-perl \
    libexif-dev \
    libexpat1-dev \
    libffi-checklib-perl \
    libfile-chdir-perl \
    libfile-slurper-perl \
    libfile-which-perl \
    libglib2.0-dev \
    libgsf-1-dev \
    libheif-dev \
    libio-socket-ssl-perl \
    libjpeg-dev \
    libjxl-dev \
    libltdl-dev \
    libmojolicious-perl \
    libnet-ssleay-perl \
    liborc-0.4-dev \
    libpath-tiny-perl \
    libpkgconfig-perl \
    librsvg2-dev \
    libsort-versions-perl \
    libspng-dev \
    libterm-table-perl \
    libtest-fatal-perl \
    libtest-needs-perl \
    libtest-warnings-perl \
    libtest2-suite-perl \
    libtool \
    libtry-tiny-perl \
    libwebp-dev \
    make \
    meson \
    pkg-config \
    unzip \
    wget && \
  echo "**** install runtime packages ****" && \
  echo "deb [signed-by=/usr/share/keyrings/nodesource-repo.gpg] https://deb.nodesource.com/node_20.x nodistro main" >>/etc/apt/sources.list.d/node.list && \
  curl -s https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor | tee /usr/share/keyrings/nodesource-repo.gpg >/dev/null && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    intel-media-va-driver-non-free \
    libexif12 \
    libexpat1 \
    libgcc-s1 \
    libglib2.0-0 \
    libgomp1 \
    libgsf-1-114 \
    libheif1 \
    libjxl0.7 \
    liblcms2-2 \
    liblqr-1-0 \
    libltdl7 \
    libmimalloc2.0 \
    libopenexr-3-1-30 \
    libopenjp2-7 \
    liborc-0.4-0 \
    libpng16-16 \
    librsvg2-2 \
    libspng0 \
    libwebp7 \
    libwebpdemux2 \
    libwebpmux3 \
    mesa-va-drivers \
    nodejs \
    perl \
    zlib1g && \
    echo "**** download immich dependencies ****" && \
  mkdir -p \
    /tmp/immich-dependencies && \
  curl -o \
    /tmp/immich-dependencies.tar.gz -L \
    "https://github.com/immich-app/base-images/archive/main.tar.gz" && \
  tar xf \
    /tmp/immich-dependencies.tar.gz -C \
    /tmp/immich-dependencies --strip-components=1 && \
  echo "**** build immich dependencies ****" && \
  cd /tmp/immich-dependencies/server/bin && \
  ./install-ffmpeg.sh && \
  ./build-libraw.sh && \
  ./build-imagemagick.sh && \
  ./build-libvips.sh && \
  ./build-perllib-compress-brotli.sh && \
  echo "**** download geocoding data ****" && \
  mkdir -p \
    /usr/src/resources && \
  curl -o \
    /tmp/cities500.zip -L \
    "https://download.geonames.org/export/dump/cities500.zip" && \
  curl -o \
    /usr/src/resources/admin1CodesASCII.txt -L \
    "https://download.geonames.org/export/dump/admin1CodesASCII.txt" && \
  curl -o \
    /usr/src/resources/admin2Codes.txt -L \
    "https://download.geonames.org/export/dump/admin2Codes.txt" && \
  unzip \
    /tmp/cities500.zip -d \
    /usr/src/resources && \
  date --iso-8601=seconds | tr -d "\n" > /usr/src/resources/geodata-date.txt && \
  echo "**** cleanup ****" && \
  apt-get remove -y --purge \
    autoconf \
    bc \
    build-essential \
    cpanminus \
    g++ \
    git \
    libany-uri-escape-perl \
    libcapture-tiny-perl \
    libexif-dev \
    libexpat1-dev \
    libffi-checklib-perl \
    libfile-chdir-perl \
    libfile-slurper-perl \
    libfile-which-perl \
    libglib2.0-dev \
    libglib2.0-dev \
    libgsf-1-dev \
    libgsf-1-dev \
    libheif-dev \
    libheif-dev \
    libio-socket-ssl-perl \
    libjpeg-dev \
    libjxl-dev \
    libltdl-dev \
    libmojolicious-perl \
    libnet-ssleay-perl \
    liborc-0.4-dev \
    libpath-tiny-perl \
    libpkgconfig-perl \
    librsvg2-dev \
    libsort-versions-perl \
    libspng-dev \
    libterm-table-perl \
    libtest-fatal-perl \
    libtest-needs-perl \
    libtest-warnings-perl \
    libtest2-suite-perl \
    libtool \
    libtry-tiny-perl \
    libwebp-dev \
    make \
    meson \
    pkg-config \
    unzip \
    wget && \
  apt-get autoremove -y --purge && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/tmp/* \
    /var/lib/apt/lists/* \
    /root/.cpanm \
    /etc/apt/sources.list.d/node.list \
    /usr/share/keyrings/nodesource.gpg
