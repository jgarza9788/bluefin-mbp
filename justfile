set shell := ["bash", "-c"]

[group('bluefin-mbp')]
setup-mbp:
    #!/usr/bin/env bash
    echo "Verifying mbpfan is active..."
    systemctl is-active mbpfan || systemctl start mbpfan
    echo "Checking Wi-Fi driver..."
    lsmod | grep wl && echo "wl driver loaded" || echo "wl not loaded — run: ujust install-wifi"

[group('bluefin-mbp')]
install-wifi:
    #!/usr/bin/env bash
    echo "Installing Broadcom Wi-Fi drivers from RPM Fusion nonfree..."
    echo "This layers packages onto your ostree deployment and requires a reboot."
    rpm-ostree install \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
        || true
    rpm-ostree install akmod-wl broadcom-wl
    echo ""
    echo "Reboot and then run: ujust check-wifi"

[group('bluefin-mbp')]
check-wifi:
    #!/usr/bin/env bash
    echo "=== Wi-Fi Driver ==="
    lsmod | grep wl && echo "wl driver loaded" || echo "WARNING: wl module not found — try rebooting once more for akmods to compile"

[group('bluefin-mbp')]
check-hw:
    #!/usr/bin/env bash
    echo "=== Thermal Management ==="
    systemctl status mbpfan --no-pager
    echo ""
    echo "=== Wi-Fi Driver ==="
    lsmod | grep wl || echo "WARNING: wl module not found (run: ujust install-wifi)"
    echo ""
    echo "=== GPU ==="
    lspci | grep -i nvidia
    lsmod | grep nouveau || echo "nouveau not loaded"
