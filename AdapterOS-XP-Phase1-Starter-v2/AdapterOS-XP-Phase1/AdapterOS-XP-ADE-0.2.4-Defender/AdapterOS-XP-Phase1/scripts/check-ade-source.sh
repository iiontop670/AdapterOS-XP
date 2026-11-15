#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

required=(
    ade/CMakeLists.txt
    ade/src/main.cpp
    ade/resources.qrc
    ade/qml/Main.qml
    ade/qml/SnakeGame.qml
    docs/ADE-0.2.4.md
    ade/wallpapers/adapteros-luna-hills.jpg
    ade/sounds/adapter-startup.wav
    ade/sounds/ui-click.wav
    ade/sounds/ui-error.wav
    config/hooks/live/9990-build-ade.hook.chroot
    config/includes.chroot/usr/local/bin/adapteros-ade-start
    config/includes.chroot/etc/xdg/autostart/adapteros-ade.desktop
    config/package-lists/adapteros-xp.list.chroot
)

for path in "${required[@]}"; do
    if [[ ! -f "$path" ]]; then
        echo "ERROR: Missing ADE 0.2.4 file: $path" >&2
        exit 1
    fi
done

if ! grep -q 'wallpapers/adapteros-luna-hills.jpg' ade/resources.qrc; then
    echo "ERROR: Bundled Luna-era wallpaper is missing from the Qt resource manifest." >&2
    exit 1
fi

if ! grep -q 'qml6-module-qtmultimedia' config/package-lists/adapteros-xp.list.chroot; then
    echo "ERROR: Qt Multimedia QML runtime package is not in the package list." >&2
    exit 1
fi

# Verify the Wi-Fi firmware and connection support requested for ADE 0.2.1.
wifi_packages=(
    firmware-iwlwifi
    firmware-realtek
    firmware-atheros
    firmware-brcm80211
    firmware-mediatek
    firmware-libertas
    firmware-ti-connectivity
    firmware-ath9k-htc
    firmware-carl9170
    firmware-zd1211
    wpasupplicant
    wireless-regdb
    iw
    rfkill
)
for package in "${wifi_packages[@]}"; do
    if ! grep -Eq "^[[:space:]]*${package}[[:space:]]*(#.*)?$" config/package-lists/adapteros-xp.list.chroot; then
        echo "ERROR: Wi-Fi package is missing from the package list: ${package}" >&2
        exit 1
    fi
done


# Verify Task Manager and system utility implementation is present.
for needle in \
    'Q_INVOKABLE QVariantList processList' \
    'Q_INVOKABLE QString terminateProcess' \
    'Q_INVOKABLE QVariantMap systemStats' \
    'Q_INVOKABLE QVariantList networkInterfaces' \
    'SIGTERM'; do
    if ! grep -Fq "$needle" ade/src/main.cpp; then
        echo "ERROR: Missing Task Manager backend implementation: $needle" >&2
        exit 1
    fi
done

for needle in \
    'Task Manager' \
    'Utilities Center' \
    'System Information' \
    'Disk Usage' \
    'Network Status' \
    'Clock and Calendar' \
    'End task'; do
    if ! grep -Fq "$needle" ade/qml/Main.qml; then
        echo "ERROR: Missing ADE utility screen: $needle" >&2
        exit 1
    fi
done

if ! grep -Eq '^[[:space:]]*procps[[:space:]]*(#.*)?$' config/package-lists/adapteros-xp.list.chroot; then
    echo "ERROR: procps is required for Task Manager process enumeration." >&2
    exit 1
fi

if ! grep -q 'QtMultimedia' ade/qml/Main.qml; then
    echo "ERROR: Main.qml does not import QtMultimedia." >&2
    exit 1
fi

if ! grep -q '9990-build-ade.hook.chroot' scripts/configure-iso.sh; then
    echo "ERROR: configure-iso.sh does not check for the ADE build hook." >&2
    exit 1
fi

python3 - <<'PY'
import os
import wave
import xml.etree.ElementTree as ET
ET.parse("ade/resources.qrc")
for filename in ("adapter-startup.wav", "ui-click.wav", "ui-error.wav"):
    path = os.path.join("ade", "sounds", filename)
    with wave.open(path, "rb") as audio:
        if audio.getnchannels() != 1 or audio.getframerate() != 44100:
            raise SystemExit(f"ERROR: Unexpected WAV format: {path}")
        if audio.getnframes() == 0:
            raise SystemExit(f"ERROR: Empty WAV file: {path}")
print("Qt resources XML and original WAV sound files are valid.")
PY

bash -n scripts/configure-iso.sh scripts/build-iso.sh scripts/clean-iso.sh
sh -n config/hooks/live/9990-build-ade.hook.chroot config/includes.chroot/usr/local/bin/adapteros-ade-start

# Defender integration sanity checks.
for package in clamav clamav-freshclam; do
    if ! grep -Eq "^[[:space:]]*${package}[[:space:]]*(#.*)?$" config/package-lists/adapteros-xp.list.chroot; then
        echo "ERROR: Defender package is missing: ${package}" >&2
        exit 1
    fi
done
for needle in \
    'Q_INVOKABLE QVariantMap defenderStatus' \
    'Q_INVOKABLE void startDefenderScan' \
    'Q_INVOKABLE QString quarantineDefenderFile' \
    'Q_INVOKABLE QString restoreDefenderFile' \
    '--heuristic-alerts=no' \
    'defenderScanFinished'; do
    if ! grep -Fq -- "$needle" ade/src/main.cpp; then
        echo "ERROR: Missing Defender backend feature: $needle" >&2
        exit 1
    fi
done
for needle in 'AdapterOS Defender' 'Conservative profile' 'Quarantine' 'Restore'; do
    if ! grep -Fq "$needle" ade/qml/Main.qml; then
        echo "ERROR: Missing Defender UI element: $needle" >&2
        exit 1
    fi
done
if grep -Eq '^[[:space:]]*(clamav-daemon|clamonacc)([[:space:]]|$)' config/package-lists/adapteros-xp.list.chroot; then
    echo "ERROR: The lightweight default profile must not install a resident scanner." >&2
    exit 1
fi
if ! grep -Fq 'systemctl --root=/ enable clamav-freshclam.service' config/hooks/live/9990-build-ade.hook.chroot; then
    echo "ERROR: FreshClam must be enabled for automatic signature updates." >&2
    exit 1
fi

echo "ADE 0.2.4 source checks passed, including Defender integration."
