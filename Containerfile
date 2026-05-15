# Build stage: compile mbpfan from source (no Fedora 44 package available yet)
FROM fedora:latest AS mbpfan-builder
RUN dnf install -y gcc make git
RUN git clone --depth=1 https://github.com/dgraziotin/mbpfan /tmp/mbpfan
WORKDIR /tmp/mbpfan
RUN make

# Main image
FROM ghcr.io/ublue-os/bluefin:latest

# Enable RPM Fusion nonfree (required for akmod-wl / broadcom-wl)
RUN rpm-ostree install \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
    || true

# Install Broadcom BCM4360 Wi-Fi drivers
# akmod-wl compiles the wl kernel module at first boot via akmods
RUN rpm-ostree install \
    akmod-wl \
    broadcom-wl \
    && rpm-ostree cleanup -m

# Install mbpfan built from source
COPY --from=mbpfan-builder /tmp/mbpfan/bin/mbpfan /usr/sbin/mbpfan
COPY --from=mbpfan-builder /tmp/mbpfan/mbpfan.conf /etc/mbpfan.conf
COPY --from=mbpfan-builder /tmp/mbpfan/mbpfan.service /usr/lib/systemd/system/mbpfan.service
RUN chmod +x /usr/sbin/mbpfan

# Enable mbpfan thermal management service at boot
RUN systemctl enable mbpfan
