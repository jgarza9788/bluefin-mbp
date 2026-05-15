set shell := ["bash", "-c"]

[group('bluefin-mbp')]
setup-mbp:
    #!/usr/bin/env bash
    echo "Verifying mbpfan is active..."
    systemctl is-active mbpfan || systemctl start mbpfan
    echo "Checking Wi-Fi driver..."
    lsmod | grep wl && echo "wl driver loaded" || echo "WARNING: wl not loaded"

[group('bluefin-mbp')]
check-hw:
    #!/usr/bin/env bash
    echo "=== Thermal Management ==="
    systemctl status mbpfan --no-pager
    echo ""
    echo "=== Wi-Fi Driver ==="
    lsmod | grep wl || echo "WARNING: wl module not found"
    echo ""
    echo "=== GPU ==="
    lspci | grep -i nvidia
    lsmod | grep nouveau || echo "nouveau not loaded"
