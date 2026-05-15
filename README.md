# bluefin-mbp

A custom [Universal Blue](https://universal-blue.org/) / Bluefin OCI image targeting MacBook Pro 2013 hardware.

[![Build and Push bluefin-mbp](https://github.com/jgarza9788/bluefin-mbp/actions/workflows/build.yml/badge.svg)](https://github.com/jgarza9788/bluefin-mbp/actions/workflows/build.yml)

## Hardware Targets

| Component | Hardware | Driver |
|-----------|----------|--------|
| Wi-Fi | Broadcom BCM4360 | `akmod-wl` / `broadcom-wl` (RPM Fusion nonfree) |
| GPU | NVIDIA GT 650M | Nouveau (open-source) |
| Thermal | MacBook Pro fans | `mbpfan` |

## What's included

- All stock [Bluefin](https://projectbluefin.io/) features (GNOME, uBlue tooling, Flatpak apps)
- Broadcom BCM4360 Wi-Fi via `akmod-wl` (recompiles the kernel module automatically on updates)
- `mbpfan` enabled at boot for proper fan speed management
- `ujust` recipes for post-install hardware verification

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

After first boot, verify hardware is working:

```bash
ujust setup-mbp   # start mbpfan + check wl driver
ujust check-hw    # full hardware status report
```

If the `wl` module is not loaded on first boot, reboot once — `akmods` compiles the Broadcom driver on first boot and it will be available after restart.

## Building locally

Requires [Docker](https://docs.docker.com/engine/install/) or [Podman](https://podman.io/).

```bash
docker build -t bluefin-mbp:local -f Containerfile .
```

## Notes

- The image tracks `bluefin:latest` and rebuilds weekly, so it stays current with upstream Fedora and Bluefin updates.
- Desktop environment is stock Bluefin GNOME — no customizations beyond hardware drivers.
- `akmod-wl` handles kernel module recompilation automatically across kernel updates via `akmods`.

## Based on

- [Bluefin](https://projectbluefin.io/) by Universal Blue
- [Universal Blue startingpoint](https://github.com/ublue-os/startingpoint)
