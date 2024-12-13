# syntax=docker/dockerfile:1

FROM ghcr.io/imagegenius/baseimage-ubuntu:noble

# set version label
ARG BUILD_DATE
ARG VERSION

ARG LATEST_UBUNTU_VERSION="oracular"
ARG CURRENT_UBUNTU_VERSION="noble"

LABEL build_version="ImageGenius Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="hydazz, martabal"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
  mkdir -p \
    /app/immich/server/geodata \
    /tmp/immich-dependencies && \
  UBUNTU_REPO="http://archive.ubuntu.com/ubuntu/" && \
  printf "deb ${UBUNTU_REPO} ${LATEST_UBUNTU_VERSION} main restricted universe multiverse\ndeb-src ${UBUNTU_REPO} ${LATEST_UBUNTU_VERSION} main restricted universe multiverse" >> /etc/apt/sources.list && \
  printf "Package: *\nPin: release n=${LATEST_UBUNTU_VERSION}\nPin-Priority: 450" > /etc/apt/preferences.d/preferences && \
  echo "deb [signed-by=/usr/share/keyrings/nodesource-repo.gpg] https://deb.nodesource.com/node_20.x nodistro main" >>/etc/apt/sources.list.d/node.list && \
  curl -s https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor | tee /usr/share/keyrings/nodesource-repo.gpg >/dev/null && \
  curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor > /usr/share/keyrings/pgdg-archive-keyring.gpg && \
  echo "deb [signed-by=/usr/share/keyrings/pgdg-archive-keyring.gpg] https://apt.postgresql.org/pub/repos/apt ${CURRENT_UBUNTU_VERSION}-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
  apt-get update && \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    autoconf \
    bc \
    build-essential \
    cmake \
    git \
    libbrotli-dev \
    libde265-dev \
    libexif-dev \
    libexpat1-dev \
    libglib2.0-dev \
    libgsf-1-dev \
    libjpeg-dev \
    libltdl-dev \
    librsvg2-dev \
    libspng-dev \
    libtool \
    libwebp-dev \
    meson \
    pkg-config \
    postgresql-client-14 \
    postgresql-client-15 \
    postgresql-client-16 \
    unzip && \
  apt-get install --no-install-recommends -y -t ${LATEST_UBUNTU_VERSION} \
    libdav1d-dev \
    libhwy-dev \
    libwebp-dev && \
  echo "**** install runtime packages ****" && \
  apt-get install --no-install-recommends -y \
    libdav1d7 \
    libde265-0 \
    libexif12 \
    libexpat1 \
    libgcc-s1 \
    libglib2.0-0 \
    libgomp1 \
    libgsf-1-114 \
    libio-compress-brotli-perl \
    liblcms2-2 \
    liblqr-1-0 \
    libltdl7 \
    libmimalloc2.0 \
    libopenexr-3-1-30 \
    libopenjp2-7 \
    libpng16-16 \
    librsvg2-2 \
    libspng0 \
    mesa-utils \
    mesa-va-drivers \
    mesa-vulkan-drivers \
    nodejs \
    perl \
    zlib1g && \
  apt-get install --no-install-recommends -y -t ${LATEST_UBUNTU_VERSION} \
    libhwy1t64 \
    libwebp7 \
    libwebpdemux2 \
    libwebpmux3 && \
  echo "**** install intel dependencies ****" && \
  apt-get install --no-install-recommends -y \
    intel-media-va-driver-non-free \
    ocl-icd-libopencl1 && \
  INTEL_DEPENDENCIES=$(curl -sX GET "https://api.github.com/repos/intel/compute-runtime/releases/latest" | jq -r '.body' | grep wget | grep -v .sum | grep -v .ddeb | sed 's|wget ||g') && \
  mkdir -p /tmp/intel && \
  for i in $INTEL_DEPENDENCIES; do \
    curl -fS --retry 3 --retry-connrefused -o \
      /tmp/intel/$(basename "${i%$'\r'}") -L \
      "${i%$'\r'}"; \
  done && \
  dpkg -i /tmp/intel/*.deb; \
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
  FFMPEG_VERSION=$(jq -cr '.packages[] | select(.name == "ffmpeg").version' /tmp/immich-dependencies/server/bin/build-lock.json) && \
  curl -o \
    /tmp/ffmpeg.deb -L \
    "https://github.com/jellyfin/jellyfin-ffmpeg/releases/download/v${FFMPEG_VERSION}/jellyfin-ffmpeg7_${FFMPEG_VERSION}-noble_amd64.deb" && \
  apt-get install --no-install-recommends -y -f \
    /tmp/ffmpeg.deb && \
  ldconfig /usr/lib/jellyfin-ffmpeg/lib && \
  ln -s /usr/lib/jellyfin-ffmpeg/ffmpeg /usr/bin && \
  ln -s /usr/lib/jellyfin-ffmpeg/ffprobe /usr/bin && \
  mv \
    /tmp/immich-dependencies/server/bin/patches/* \
    /tmp/immich-dependencies/server/bin && \
  ./build-libjxl.sh \
    --JPEGLI_LIBJPEG_LIBRARY_SOVERSION 8 \
    --JPEGLI_LIBJPEG_LIBRARY_VERSION 8.2.2 && \
  ./build-libheif.sh && \
  ./build-libraw.sh && \
  ./build-imagemagick.sh && \
  ./build-libvips.sh && \
  mv \
    /tmp/immich-dependencies/server/bin/build-lock.json \
    /app/immich/server && \
  echo "**** download geocoding data ****" && \
  curl -o \
    /tmp/cities500.zip -L \
    "https://download.geonames.org/export/dump/cities500.zip" && \
  curl -o \
    /app/immich/server/geodata/admin1CodesASCII.txt -L \
    "https://download.geonames.org/export/dump/admin1CodesASCII.txt" && \
  curl -o \
    /app/immich/server/geodata/admin2Codes.txt -L \
    "https://download.geonames.org/export/dump/admin2Codes.txt" && \
  curl -o \
    /app/immich/server/geodata/ne_10m_admin_0_countries.geojson -L \
    "https://raw.githubusercontent.com/nvkelso/natural-earth-vector/v5.1.2/geojson/ne_10m_admin_0_countries.geojson" && \
  unzip \
    /tmp/cities500.zip -d \
    /app/immich/server/geodata && \
  date --iso-8601=seconds | tr -d "\n" > /app/immich/server/geodata/geodata-date.txt && \
  echo "**** cleanup ****" && \
  apt-get remove -y --purge \
    autoconf \
    bc \
    build-essential \
    cmake \
    git \
    libdav1d-dev \
    libde265-dev \
    libexif-dev \
    libexpat1-dev \
    libglib2.0-dev \
    libgsf-1-dev \
    libheif-dev \
    libhwy-dev \
    libjpeg-dev \
    libltdl-dev \
    libbrotli-dev \
    librsvg2-dev \
    libspng-dev \
    libtool \
    libwebp-dev \
    meson \
    pkg-config \
    unzip && \
  apt-get autoremove -y --purge && \
  apt-get clean && \
  rm -rf \
    /etc/apt/sources.list.d/node.list \
    /tmp/* \
    /usr/share/keyrings/nodesource.gpg \
    /usr/share/keyrings/pgdg-archive-keyring.gpg \
    /var/lib/apt/lists/* \
    /var/log/* \
    /var/tmp/*
