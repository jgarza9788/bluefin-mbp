# Building a Bootable ISO with bootc-image-builder

This produces a USB-flashable installer ISO from the `ghcr.io/jgarza9788/bluefin-mbp:latest`
OCI image, so you can install directly without a rebase step.

## Requirements

- **Linux host** (or WSL2 on Windows — see note below)
- `podman` installed (rootful mode required)
- ~10 GB free disk space for the build output
- The image must be publicly accessible on ghcr.io (it is, by default for public repos)

> **Windows / WSL2:** Run these commands inside a WSL2 terminal. WSL2 has podman available
> via `sudo apt install podman` (Ubuntu) or equivalent. The output file lands in your WSL2
> filesystem; copy it to Windows with `cp ./output/... /mnt/c/Users/...` before flashing.

---

## Step 1 — Create a config.toml

`config.toml` sets up the initial user account baked into the installer.

```toml
[[customizations.user]]
name = "jgarza"
password = "changeme"        # change before building, or use a hashed password
groups = ["wheel"]
```

To use a hashed password instead (recommended):

```bash
openssl passwd -6
# paste the output hash as the password value
```

---

## Step 2 — Run bootc-image-builder

```bash
mkdir -p output

sudo podman run \
  --rm \
  --privileged \
  --pull=newer \
  --security-opt label=type:unconfined_t \
  -v ./config.toml:/config.toml:ro \
  -v ./output:/output \
  -v /var/lib/containers/storage:/var/lib/containers/storage \
  quay.io/centos-bootc/bootc-image-builder:latest \
  --type anaconda-iso \
  --config /config.toml \
  ghcr.io/jgarza9788/bluefin-mbp:latest
```

The build takes 10–20 minutes depending on your connection and CPU.

### Output

```
output/
└── anaconda-iso/
    └── disk.iso     ← flash this to USB
```

---

## Step 3 — Flash to USB

Find your USB device first — **double-check the device name or you will overwrite the wrong disk**:

```bash
lsblk          # on Linux
# or
diskutil list  # on macOS
```

Then flash:

```bash
sudo dd if=./output/anaconda-iso/disk.iso of=/dev/sdX bs=4M status=progress
sudo sync
```

Replace `/dev/sdX` with your actual USB device (e.g. `/dev/sdb`). Do **not** use a partition
(e.g. `/dev/sdb1`) — target the whole disk.

---

## Notes

- `bootc-image-builder` requires a **bootc-compatible** image. Universal Blue / Bluefin images
  are bootc-compatible as of Fedora 41+, so `bluefin-mbp:latest` works.
- The resulting installer is **unattended by default** — it will deploy to the first detected
  disk automatically. Review the Anaconda config if you need an interactive installer.
- If the build fails with a permission error on SELinux hosts, install `osbuild-selinux`:
  ```bash
  sudo dnf install osbuild-selinux
  ```
- After flashing, eject safely:
  ```bash
  sudo eject /dev/sdX
  ```

---

## References

- [bootc-image-builder GitHub](https://github.com/osbuild/bootc-image-builder)
- [osbuild.org bootc docs](https://osbuild.org/docs/bootc/)
