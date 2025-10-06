#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

CFG="${CFG:-./openssl-san.cnf}"
KEY="app.key"
CRT="app.crt"
DAYS="${DAYS:-3650}"

openssl req -x509 -nodes -newkey rsa:2048 \
  -keyout "$KEY" \
  -out "$CRT" \
  -days "$DAYS" \
  -config "$CFG"

echo "[OK] SAN cert generated:"
echo "  Key: $(pwd)/$KEY"
echo "  Cert: $(pwd)/$CRT"
