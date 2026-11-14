#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v lb >/dev/null 2>&1; then
  echo "live-build is missing. Install it with: sudo apt install live-build" >&2
  exit 1
fi

if [[ "${EUID}" -eq 0 ]]; then
  LB=(lb)
else
  LB=(sudo lb)
fi

"${LB[@]}" config noauto \
  --mode debian \
  --distribution trixie \
  --architectures amd64 \
  --binary-image iso-hybrid \
  --archive-areas "main contrib non-free-firmware" \
  --bootappend-live "boot=live components username=adapteros hostname=adapteros"

echo "AdapterOS ISO configuration created."
