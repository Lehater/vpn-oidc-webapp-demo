#!/usr/bin/env bash
set -euo pipefail
# REPO_ROOT = <repo>/ (независимо от того, откуда запускаем)
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

mkdir -p "${REPO_ROOT}/artifacts/keys"
umask 077

if [[ ! -f "${REPO_ROOT}/artifacts/keys/server.key" ]]; then
  wg genkey | tee "${REPO_ROOT}/artifacts/keys/server.key" | wg pubkey > "${REPO_ROOT}/artifacts/keys/server.pub"
  echo "[OK] Generated server keys"
else
  echo "[SKIP] Server keys exist"
fi

if [[ ! -f "${REPO_ROOT}/artifacts/keys/client1.key" ]]; then
  wg genkey | tee "${REPO_ROOT}/artifacts/keys/client1.key" | wg pubkey > "${REPO_ROOT}/artifacts/keys/client1.pub"
  echo "[OK] Generated client1 keys"
else
  echo "[SKIP] Client1 keys exist"
fi

echo "${REPO_ROOT}/artifacts/keys"
ls -l "${REPO_ROOT}/artifacts/keys"
