#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -f config/binary ]]; then
  echo "No live-build configuration found. Run ./scripts/configure-iso.sh first." >&2
  exit 1
fi

if [[ "${EUID}" -eq 0 ]]; then
  lb build
else
  sudo lb build
fi
echo
echo "Build finished. Look for live-image-amd64.hybrid.iso in:"
pwd
