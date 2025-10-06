#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"/..

# Решает: безопасная генерация ключей для сервера и клиента
mkdir -p ../../artifacts/keys
umask 077

if [[ ! -f ../../artifacts/keys/server.key ]]; then
  wg genkey | tee ../../artifacts/keys/server.key | wg pubkey > ../../artifacts/keys/server.pub
  echo "[OK] Generated server keys"
else
  echo "[SKIP] Server keys exist"
fi

if [[ ! -f ../../artifacts/keys/client1.key ]]; then
  wg genkey | tee ../../artifacts/keys/client1.key | wg pubkey > ../../artifacts/keys/client1.pub
  echo "[OK] Generated client1 keys"
else
  echo "[SKIP] Client1 keys exist"
fi
