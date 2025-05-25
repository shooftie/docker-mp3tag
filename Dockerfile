FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

LABEL maintainer="shooftie"

ENV TITLE=Mp3tag

ARG mp3tag_img_src="https://www.mp3tag.de/images/logo.png"
ARG mp3tag_favicon_src="https://mp3tag.app/favicon.ico"
ARG mp3tag_installer="mp3tagv328-x64-setup.exe"
ARG mp3tag_src="https://download.mp3tag.de/${mp3tag_installer}"
ARG mp3tag_installer_path="/media/${mp3tag_installer}"
ARG mp3tag_script_dir="/usr/local/bin"
ARG mp3tag_script="mp3tag"
ARG mp3tag_script_path="${mp3tag_script_dir}/${mp3tag_script}"

# Install Wine sources
RUN \
  dpkg --add-architecture i386 && \
  mkdir -p -m 755 /etc/apt/keyrings && \
  curl \
    -o /etc/apt/keyrings/winehq-archive.key \
    https://dl.winehq.org/wine-builds/winehq.key && \
  curl -s \
    -z /etc/apt/sources.list.d/winehq-bookworm.sources \
    -o /etc/apt/sources.list.d/winehq-bookworm.sources \
    https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources

# Install Wine
RUN \
  dpkg --add-architecture i386 && \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y --install-recommends winehq-stable && \
  echo "$(wine --version) | $(which wine)"

# Download Mp3tag – the interactive process means that we cannot install it into
# wine here. Instead, we handle that in the autostart script but we can bundle
# up the dependency anyway.
RUN \
  curl \
    -o /kclient/public/icon.png \
    "${mp3tag_img_src}" && \
  curl \
    -o /kclient/public/favicon.png \
    "${mp3tag_img_src}" && \
  curl -SL \
    -o "${mp3tag_installer_path}" \
    "${mp3tag_src}"

# Add Mp3tag script – this is where we ensure that Wine is configured, install
# Mp3tag into it and then once all tasks are complete, run it with the necessary
# environment variables.
ENV MP3TAG_SRC=${mp3tag_src}
ENV MP3TAG_INSTALLER=${mp3tag_installer}
ENV MP3TAG_INSTALLER_PATH=${mp3tag_installer_path}

ADD ${mp3tag_script} ${mp3tag_script_dir}
RUN chmod 755 ${mp3tag_script_path}

# Install Picard
RUN \
  apt-get install -y picard

# Install Firefox
# TODO

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
