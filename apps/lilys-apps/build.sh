#!/usr/bin/bash

set -ouex pipefail

dnf -y upgrade

# Install packages required by Distrobox, this speeds up the first-run time
dnf install -y \
    bash-completion \
    bc \
    bzip2 \
    curl \
    diffutils \
    dnf-plugins-core \
    findutils \
    fish \
    glibc-all-langpacks \
    glibc-locale-source \
    gnupg2 \
    gnupg2-smime \
    hostname \
    iproute \
    iputils \
    keyutils \
    krb5-libs \
    less \
    lsof \
    man-db \
    man-pages \
    mtr \
    ncurses \
    nss-mdns \
    openssh-clients \
    pam \
    passwd \
    pigz \
    pinentry \
    procps-ng \
    rsync \
    shadow-utils \
    sudo \
    tcpdump \
    time \
    traceroute \
    tree \
    tzdata \
    unzip \
    util-linux \
    vte-profile \
    wget \
    which \
    whois \
    words \
    xorg-x11-xauth \
    xz \
    zip \
    mesa-dri-drivers \
    mesa-vulkan-drivers \
    vulkan \
    zsh

# Set up dependencies
git clone https://github.com/89luca89/distrobox.git --single-branch /tmp/distrobox
cp /tmp/distrobox/distrobox-host-exec /usr/bin/distrobox-host-exec
wget https://github.com/1player/host-spawn/releases/download/$(cat /tmp/distrobox/distrobox-host-exec | grep host_spawn_version= | cut -d "\"" -f 2)/host-spawn-$(uname -m) -O /usr/bin/host-spawn
chmod +x /usr/bin/host-spawn
rm -drf /tmp/distrobox
dnf install -y 'dnf-command(copr)'

# Set up cleaner Distrobox integration
dnf copr enable -y kylegospo/distrobox-utils
dnf install -y \
    xdg-utils-distrobox \
    adw-gtk3-theme
ln -s /usr/bin/distrobox-host-exec /usr/bin/flatpak

# Install RPMFusion for hardware accelerated encoding/decoding
dnf install -y \
    https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf install -y \
    intel-media-driver \
    nvidia-vaapi-driver
dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld

# Add 1Password
rpm --import https://downloads.1password.com/linux/keys/1password.asc
sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\""\
    > /etc/yum.repos.d/1password.repo'
dnf install -y 1password
mkdir /etc/1password
echo "vivaldi-bin" > /etc/1password/custom_allowed_browsers
chown root:root /etc/1password/custom_allowed_browsers
chmod 644 /etc/1password/custom_allowed_browsers

# Add Vivaldi
vivaldi_url=$(wget -q -O - https://vivaldi.com/download/ | grep -Eo "https://downloads.vivaldi.com/stable/vivaldi-stable-[0-9.-]+x86_64.rpm")
dnf install -y $vivaldi_url

# Add Proton Mail
dnf install -y https://proton.me/download/mail/linux/ProtonMail-desktop-beta.rpm

dnf clean all
