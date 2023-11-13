# syntax=docker/dockerfile:1

FROM ghcr.io/imagegenius/baseimage-ubuntu:lunar

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
    g++ \
    libexif-dev \
    libexpat1-dev \
    libglib2.0-dev \
    libgsf-1-dev \
    libheif-dev \
    libjpeg-dev \
    libjxl-dev \
    libltdl-dev \
    liborc-0.4-dev \
    librsvg2-dev \
    libspng-dev \
    libtool \
    libwebp-dev \
    make \
    meson \
    ninja-build \
    pkg-config \
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
    nginx \
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
  ./build-libraw.sh || ./build-libraw.sh && \
  ./build-imagemagick.sh && \
  ./build-libvips.sh && \
  echo "**** cleanup ****" && \
  apt-get remove -y --purge \
    autoconf \
    bc \
    build-essential \
    g++ \
    libexif-dev \
    libexpat1-dev \
    libglib2.0-dev \
    libgsf-1-dev \
    libheif-dev \
    libjpeg-dev \
    libjxl-dev \
    libltdl-dev \
    liborc-0.4-dev \
    librsvg2-dev \
    libspng-dev \
    libtool \
    libwebp-dev \
    make \
    meson \
    ninja-build \
    pkg-config \
    wget && \
  apt-get autoremove -y --purge && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/tmp/* \
    /var/lib/apt/lists/* \
    /root/.cache \
    /root/.npm \
    /etc/apt/sources.list.d/node.list \
    /usr/share/keyrings/nodesource.gpg
