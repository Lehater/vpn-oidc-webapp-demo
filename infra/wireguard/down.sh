#!/usr/bin/env bash
set -euo pipefail
sudo systemctl stop wg-quick@wg0 || true
echo "[OK] WireGuard down: wg0"
