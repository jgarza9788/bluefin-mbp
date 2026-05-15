# bluefin-mbp

A custom [Universal Blue](https://universal-blue.org/) / Bluefin OCI image targeting MacBook Pro 2013 hardware.

[![Build and Push bluefin-mbp](https://github.com/jgarza9788/bluefin-mbp/actions/workflows/build.yml/badge.svg)](https://github.com/jgarza9788/bluefin-mbp/actions/workflows/build.yml)

## Hardware Targets

| Component | Hardware | Driver | Status |
|-----------|----------|--------|--------|
| Wi-Fi | Broadcom BCM4360 | `akmod-wl` / `broadcom-wl` (RPM Fusion nonfree) | Manual post-rebase step (not yet in F44 repos) |
| GPU | NVIDIA GT 650M | Nouveau (open-source) | Built into kernel |
| Thermal | MacBook Pro fans | `mbpfan` | Included in image |

## What's included

- All stock [Bluefin](https://projectbluefin.io/) features (GNOME, uBlue tooling, Flatpak apps)
- `mbpfan` enabled at boot for proper fan speed management
- `ujust` recipes for post-install hardware setup and verification

## Rebase from any Fedora Atomic desktop

```bash
# Step 1 — rebase to unsigned image to get the signing key
rpm-ostree rebase ostree-unverified-registry:ghcr.io/jgarza9788/bluefin-mbp:latest

# Step 2 — reboot
systemctl reboot

# Step 3 — rebase to signed image
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/jgarza9788/bluefin-mbp:latest

# Step 4 — reboot again
systemctl reboot
```

## Post-install

After first boot, run the setup recipe and check hardware status:

```bash
ujust setup-mbp   # verify mbpfan is running
ujust check-hw    # full hardware status report
```

## Wi-Fi setup

`broadcom-wl` and `akmod-wl` are not yet packaged for Fedora 44 in RPM Fusion nonfree.
Once you're on the live system, check RPM Fusion availability and install:

```bash
ujust install-wifi   # installs broadcom-wl + akmod-wl, then reboot
ujust check-wifi     # confirm wl module is loaded
```

Once RPM Fusion ships F44 packages, Wi-Fi will be moved back into the image automatically.

## Building locally

Requires [Docker](https://docs.docker.com/engine/install/) or [Podman](https://podman.io/).

```bash
docker build -t bluefin-mbp:local -f Containerfile .
```

## Notes

- The image tracks `bluefin:latest` and rebuilds weekly, staying current with Fedora and Bluefin updates.
- Desktop environment is stock Bluefin GNOME — no customizations beyond hardware drivers.
- `mbpfan` is compiled from source ([dgraziotin/mbpfan](https://github.com/dgraziotin/mbpfan)) until an official F44 package lands.

## Based on

- [Bluefin](https://projectbluefin.io/) by Universal Blue
- [Universal Blue startingpoint](https://github.com/ublue-os/startingpoint)
