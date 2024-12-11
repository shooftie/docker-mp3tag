FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

LABEL maintainer="shooftie"

ENV TITLE=Mp3tag

# Install Wine sources
RUN \
  sudo dpkg --add-architecture i386 && \
  mkdir -pm755 /etc/apt/keyrings && \
  curl \
    -o /etc/apt/keyrings/winehq-archive.key \
    https://dl.winehq.org/wine-builds/winehq.key

# Install Wine
RUN \
  curl -s \
    -z /etc/apt/sources.list.d/winehq-bookworm.sources \
    -o /etc/apt/sources.list.d/winehq-bookworm.sources \
    https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources && \
  apt-get update && \
  apt-get install -y --install-recommends winehq-stable && \
  echo `wine --version` && \
  echo `which wine`

# Download Mp3tag and icon image
RUN \
  curl \
    -o /tmp/mp3tagv328-x64-setup.exe \
    https://download.mp3tag.de/mp3tagv328-x64-setup.exe && \
  curl \
    -o /kclient/public/icon.png \
    https://www.mp3tag.de/images/logo.png

# Cleanup
RUN \
  apt-get autoclean && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

COPY /root /

EXPOSE 3000

VOLUME /config
