#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ -x scripts/check-ade-source.sh ]]; then
    echo "Checking ADE 0.2.4 source before configuring the ISO..."
    bash scripts/check-ade-source.sh
else
    echo "ERROR: scripts/check-ade-source.sh is missing or not executable." >&2
    exit 1
fi

if ! command -v lb >/dev/null 2>&1; then
    echo "ERROR: live-build is missing. Install Debian live-build first." >&2
    exit 1
fi

if [[ "${EUID}" -eq 0 ]]; then
    LB=(lb)
    ROOT=()
else
    if ! command -v sudo >/dev/null 2>&1; then
        echo "ERROR: sudo is required when running as a normal user." >&2
        exit 1
    fi
    LB=(sudo lb)
    ROOT=(sudo)
fi

if [[ ! -f ade/CMakeLists.txt || ! -f ade/src/main.cpp || ! -f ade/qml/Main.qml ]]; then
    echo "ERROR: ADE source files are missing. Expected ade/CMakeLists.txt, ade/src/main.cpp and ade/qml/Main.qml." >&2
    exit 1
fi

if [[ ! -f config/hooks/live/9990-build-ade.hook.chroot ]]; then
    echo "ERROR: ADE live-build hook is missing." >&2
    exit 1
fi

# Debian 13 uses the trixie-security suite. Disable live-build's legacy
# automatically generated security suite and add the current suite explicitly.
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

# Add the correct Debian 13 security repository for package installation and
# for the running live environment.
"${ROOT[@]}" install -d -m 0755 config/archives
"${ROOT[@]}" rm -f \
    config/archives/debian-security.list.chroot \
    config/archives/debian-security.list.binary

printf '%s\n' \
    'deb https://security.debian.org/debian-security trixie-security main contrib non-free-firmware' \
    | "${ROOT[@]}" tee config/archives/debian-security.list.chroot >/dev/null

printf '%s\n' \
    'deb https://security.debian.org/debian-security trixie-security main contrib non-free-firmware' \
    | "${ROOT[@]}" tee config/archives/debian-security.list.binary >/dev/null

# Stage ADE's source code into the image so it can be compiled inside the
# Debian Trixie chroot, avoiding host/guest Qt ABI mismatches.
ADE_STAGE="config/includes.chroot/usr/src/adapteros/ade"
"${ROOT[@]}" rm -rf "$ADE_STAGE"
"${ROOT[@]}" install -d -m 0755 "$ADE_STAGE"
"${ROOT[@]}" cp -a ade/. "$ADE_STAGE/"

# Ensure the build hook is executable for live-build.
"${ROOT[@]}" chmod 0755 config/hooks/live/9990-build-ade.hook.chroot

# Set executable permissions for the startup helper included in the image.
"${ROOT[@]}" chmod 0755 config/includes.chroot/usr/local/bin/adapteros-ade-start

echo "AdapterOS XP 0.2.4 ISO configuration created."
echo "Target: Debian 13 Trixie amd64"
echo "Desktop: ADE 0.2.4 (KWin compositor, custom ADE shell with Task Manager and utilities)"
echo "Security suite: trixie-security"
