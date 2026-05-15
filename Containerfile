FROM ghcr.io/ublue-os/bluefin:latest

# Enable RPM Fusion nonfree (required for akmod-wl / broadcom-wl)
RUN rpm-ostree install \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
    || true

# mbpfan is not in Fedora or RPM Fusion — enable its COPR before installing
RUN curl -fsSL \
    "https://copr.fedorainfracloud.org/coprs/mrwojtas/mbpfan/repo/fedora-$(rpm -E %fedora)/mrwojtas-mbpfan-fedora-$(rpm -E %fedora).repo" \
    -o /etc/yum.repos.d/mrwojtas-mbpfan.repo

# Install Broadcom BCM4360 Wi-Fi drivers and mbpfan thermal management
# akmod-wl compiles the wl kernel module at first boot via akmods
RUN rpm-ostree install \
    akmod-wl \
    broadcom-wl \
    mbpfan \
    && rpm-ostree cleanup -m

# Enable mbpfan thermal management service at boot
RUN systemctl enable mbpfan
