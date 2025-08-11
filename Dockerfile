# Base Image
FROM ubuntu:22.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Set VNC password, which can be overridden at build time
ARG VNC_PASSWD=password
ENV VNC_PASSWD=${VNC_PASSWD}

# 1. Install Dependencies: VNC, Desktop, Supervisor, Java, KVM, and other tools
RUN apt-get update && apt-get install -y \
    supervisor \
    tightvncserver \
    xfce4 \
    xfce4-goodies \
    novnc \
    websockify \
    net-tools \
    openjdk-17-jdk \
    wget \
    unzip \
    qemu-kvm \
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    && apt-get purge -y xfce4-power-manager xfce4-power-manager-data \
    && rm -rf /var/lib/apt/lists/*

# 2. Setup VNC, Supervisor & KVM
RUN mkdir -p /var/log/supervisor && \
    mkdir -p /root/.vnc && \
    echo "${VNC_PASSWD}" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    adduser root kvm

# Setup the startup script for the VNC server to launch the XFCE desktop
RUN echo "#!/bin/bash" > /root/.vnc/xstartup && \
    echo "xrdb \$HOME/.Xresources" >> /root/.vnc/xstartup && \
    echo "startxfce4 &" >> /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Copy supervisor configuration
COPY supervisord.conf /etc/supervisor/supervisord.conf

# Expose Ports:
# 6080: noVNC Web Interface
# 5901: VNC Server (for display :1)
EXPOSE 6080 5901

# Command to run supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
