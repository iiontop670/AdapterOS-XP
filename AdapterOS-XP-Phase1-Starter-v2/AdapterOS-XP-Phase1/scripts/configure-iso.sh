
#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Check that live-build is installed.
if ! command -v lb >/dev/null 2>&1; then
    echo "ERROR: live-build is missing."
    echo "Install it with: sudo apt install live-build"
    exit 1
fi

# Select whether to run live-build directly or through sudo.
if [[ "${EUID}" -eq 0 ]]; then
    LB=(lb)
else
    if ! command -v sudo >/dev/null 2>&1; then
        echo "ERROR: sudo is required when running as a normal user."
        exit 1
    fi

    LB=(sudo lb)
fi

echo "Configuring AdapterOS XP..."
echo "Target: Debian 13 Trixie"
echo "Architecture: amd64"

# Configure the main live-build system.
# Security repositories are disabled here because the current
# live-build-generated Trixie security suite is incorrect.
"${LB[@]}" config noauto \
    --mode debian \
    --distribution trixie \
    --architectures amd64 \
    --binary-image iso-hybrid \
    --archive-areas "main contrib non-free-firmware" \
    --mirror-bootstrap "https://deb.debian.org/debian/" \
    --mirror-chroot "https://deb.debian.org/debian/" \
    --mirror-binary "https://deb.debian.org/debian/" \
    --security false \
    --updates true \
    --bootappend-live "boot=live components username=adapteros hostname=adapteros"

# Create the custom APT archive configuration directory.
ARCHIVE_DIR="config/archives"

if [[ "${EUID}" -eq 0 ]]; then
    install -d -m 0755 "$ARCHIVE_DIR"
else
    sudo install -d \
        -m 0755 \
        -o "$(id -u)" \
        -g "$(id -g)" \
        "$ARCHIVE_DIR"
fi

# Remove previous copies so this script can safely be rerun.
rm -f \
    "$ARCHIVE_DIR/debian-security.list.chroot" \
    "$ARCHIVE_DIR/debian-security.list.binary"

# Correct Debian 13 security repository for the build environment.
cat > "$ARCHIVE_DIR/debian-security.list.chroot" <<'EOF'
deb https://security.debian.org/debian-security trixie-security main contrib non-free-firmware
EOF

# Add the same security repository to the finished live system.
cat > "$ARCHIVE_DIR/debian-security.list.binary" <<'EOF'
deb https://security.debian.org/debian-security trixie-security main contrib non-free-firmware
EOF

echo
echo "AdapterOS XP configuration created successfully."
echo "Debian security repository: trixie-security"
echo "Architecture: amd64"
echo "Build system: live-build"
