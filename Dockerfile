# Base Image
FROM ubuntu:22.04

ARG OPENJDK_VERSION
# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install Dependencies: VNC, Desktop, Supervisor, Java, KVM, and other tools
RUN apt-get update && apt-get install -y \
    dbus-x11 \
    supervisor \
    tightvncserver \
    xfce4 \
    xfce4-goodies \
    novnc \
    websockify \
    net-tools \
    openjdk-${OPENJDK_VERSION}-jdk \
    wget \
    unzip \
    qemu-kvm \
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    w3m \
    locales \
    fonts-wqy-microhei \
    fonts-wqy-zenhei \
    scrcpy \
    dos2unix \
    && apt-get purge -y xfce4-power-manager xfce4-power-manager-data \
    && rm -rf /var/lib/apt/lists/*

# Setup VNC, Supervisor & KVM
RUN mkdir -p /var/log/supervisor && \
    mkdir -p /root/.vnc && \
    adduser root kvm

# Copy startup scripts
COPY start-android.sh /usr/local/bin/start-android.sh
RUN chmod +x /usr/local/bin/start-android.sh
COPY start-vnc.sh /usr/local/bin/start-vnc.sh
RUN chmod +x /usr/local/bin/start-vnc.sh
RUN dos2unix /usr/local/bin/*.sh

# Setup the startup script for the VNC server to launch the XFCE desktop
RUN echo "#!/bin/bash" > /root/.vnc/xstartup && \
    echo "xrdb \$HOME/.Xresources" >> /root/.vnc/xstartup && \
    echo "startxfce4 &" >> /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Copy supervisor configuration
COPY supervisord.conf /etc/supervisor/supervisord.conf

# 配置 locale 为中文 UTF-8
RUN locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8

ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

# 配置 w3m 默认使用 UTF-8
RUN mkdir -p /root/.w3m && \
    echo "charset UTF-8" >> /root/.w3m/config && \
    echo "display_charset UTF-8" >> /root/.w3m/config

# Expose Ports:
# 6080: noVNC Web Interface
# 5901: VNC Server (for display :1)
EXPOSE 6080 5901

# Command to run supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
