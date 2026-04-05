FROM debian:bookworm-slim

LABEL author="Custom" maintainer="you@example.com"

ENV DEBIAN_FRONTEND=noninteractive

# Create container user (matches Pterodactyl expectations)
RUN useradd -m -d /home/container -s /bin/bash container

# Install base dependencies (mirrors parkervcp base_debian)
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    iproute2 \
    tar \
    locales \
    tini \
 && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
 && locale-gen \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Enable i386 architecture and install Source Engine / SteamCMD dependencies
RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    # 32-bit libs for SteamCMD / SRCDS
    lib32gcc-s1 \
    lib32stdc++6 \
    lib32z1 \
    libsdl2-2.0-0:i386 \
    libcurl4:i386 \
    libcurl3-gnutls:i386 \
    libtinfo6:i386 \
    libncurses6:i386 \
    libncursesw6:i386 \
    libtcmalloc-minimal4:i386 \
    faketime:i386 \
    # 64-bit libs
    libtinfo6 \
    libstdc++6 \
    libncursesw6 \
    libfontconfig1 \
    libnss-wrapper \
    gettext-base \
    libc++-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install rcon-cli (updated version)
RUN cd /tmp/ \
 && curl -sSL https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz > rcon.tar.gz \
 && tar xvf rcon.tar.gz \
 && mv rcon-0.10.3-amd64_linux/rcon /usr/local/bin/ \
 && rm -rf /tmp/*

USER        container
ENV         HOME=/home/container
WORKDIR     /home/container

COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/bin/bash", "/entrypoint.sh"]
