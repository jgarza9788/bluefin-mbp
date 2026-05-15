# Build stage: compile mbpfan from source (no Fedora 44 package available yet)
FROM fedora:latest AS mbpfan-builder
RUN dnf install -y gcc make git
RUN git clone --depth=1 https://github.com/dgraziotin/mbpfan /tmp/mbpfan
WORKDIR /tmp/mbpfan
RUN make

# Main image
FROM ghcr.io/ublue-os/bluefin:latest

# NOTE: broadcom-wl / akmod-wl are not yet packaged for Fedora 44 in RPM Fusion nonfree.
# Wi-Fi must be installed manually after rebase — see README "Wi-Fi setup" section.

# Install mbpfan built from source
COPY --from=mbpfan-builder /tmp/mbpfan/bin/mbpfan /usr/sbin/mbpfan
COPY --from=mbpfan-builder /tmp/mbpfan/mbpfan.conf /etc/mbpfan.conf
COPY --from=mbpfan-builder /tmp/mbpfan/mbpfan.service /usr/lib/systemd/system/mbpfan.service
RUN chmod +x /usr/sbin/mbpfan

# Enable mbpfan thermal management service at boot
RUN systemctl enable mbpfan
