# Claude Code Prompt: bluefin-mbp — Custom Bluefin Image for MacBook Pro 2013

## Goal
Create a GitHub repository called `bluefin-mbp` — a custom Universal Blue / Bluefin OCI image
targeting MacBook Pro 2013 hardware (Broadcom BCM4360 Wi-Fi, NVIDIA GT 650M via Nouveau,
mbpfan thermal management).

---

## Tasks

### 1. Scaffold the repo by cloning the startingpoint template

```
Use the Universal Blue startingpoint template as the base:
https://github.com/ublue-os/startingpoint

Clone it locally and rename the project to `bluefin-mbp`.
Update all references to `startingpoint` → `bluefin-mbp` in:
- README.md
- .github/workflows/*.yml
- Any metadata files (image.yml, recipe.yml if present)
```

---

### 2. Update the Containerfile

Modify `Containerfile` to:

1. Base from the latest stable Bluefin image:
   ```dockerfile
   FROM ghcr.io/ublue-os/bluefin:latest
   ```

2. Enable RPM Fusion nonfree (required for akmod-wl):
   ```dockerfile
   RUN rpm-ostree install \
       https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
       || true
   ```

3. Install Broadcom Wi-Fi drivers + thermal management:
   ```dockerfile
   RUN rpm-ostree install \
       akmod-wl \
       broadcom-wl \
       mbpfan \
       && rpm-ostree cleanup -m
   ```

4. Enable mbpfan service at boot:
   ```dockerfile
   RUN systemctl enable mbpfan
   ```

---

### 3. Add a `bluefin-mbp.yml` or `recipe.yml` config (if startingpoint uses one)

Set:
- `name: bluefin-mbp`
- `description: Bluefin-based OCI image for MacBook Pro 2013`
- `base-image: ghcr.io/ublue-os/bluefin`
- `image-version: latest`

---

### 4. Update GitHub Actions workflow

In `.github/workflows/build.yml` (or equivalent):
- Set image name to `bluefin-mbp`
- Push to `ghcr.io/<your-github-username>/bluefin-mbp`
- Trigger on push to `main` and weekly schedule

---

### 5. Update README.md

Replace template content with:
- Project name: `bluefin-mbp`
- Description: Custom Bluefin image for MacBook Pro 2013
- Hardware targets: BCM4360 Wi-Fi, GT 650M (Nouveau), mbpfan
- Rebase instructions:
  ```bash
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/<username>/bluefin-mbp:latest
  ```

---

### 6. Add a `justfile` or `ujust` recipe (optional but nice)

Add a post-install helper:
```just
[group('bluefin-mbp')]
setup-mbp:
    #!/usr/bin/env bash
    echo "Verifying mbpfan is active..."
    systemctl is-active mbpfan || systemctl start mbpfan
    echo "Checking Wi-Fi driver..."
    lsmod | grep wl && echo "wl driver loaded" || echo "WARNING: wl not loaded"
```

---

## Constraints

- Do not use deprecated `rpm-ostree override` unless necessary
- Keep Containerfile clean and layered minimally
- All driver installs must survive `ostree` updates (akmod handles this)
- Do not add any desktop environment changes — keep stock Bluefin GNOME
- Do not pin to a specific Fedora version — track `latest`

---

## Deliverables

- [ ] Full repo scaffold at `./bluefin-mbp/`
- [ ] Working `Containerfile`
- [ ] GitHub Actions workflow that builds and pushes to ghcr.io
- [ ] Updated `README.md`
- [ ] Optional: `justfile` with `setup-mbp` recipe
