#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "${EUID}" -eq 0 ]]; then
  lb clean --purge
else
  sudo lb clean --purge
fi
echo "Generated live-build state cleaned."
