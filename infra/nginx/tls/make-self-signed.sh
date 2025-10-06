#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

CN="${CN:-app.vpn.local}"
DAYS="${DAYS:-3650}"

openssl req -x509 -nodes -newkey rsa:2048 \
  -keyout app.key \
  -out app.crt \
  -days "$DAYS" \
  -subj "/CN=${CN}"

echo "[OK] Self-signed cert generated: $(pwd)/app.crt"
