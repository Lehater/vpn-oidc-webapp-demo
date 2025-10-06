#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

source "${SCRIPT_DIR}/server.env"

# --- helper: escape value for sed replacement ---
escape() {
  # экранируем \, |, &, /
  # shellcheck disable=SC2001
  echo "$1" | sed -e 's/[\/&|\\]/\\&/g'
}

# читаем значения
SERVER_PRIV_RAW="$(cat "${REPO_ROOT}/artifacts/keys/server.key")"
SERVER_PUB_RAW="$(cat "${REPO_ROOT}/artifacts/keys/server.pub")"
CLIENT1_PRIV_RAW="$(cat "${REPO_ROOT}/artifacts/keys/client1.key")"
CLIENT1_PUB_RAW="$(cat "${REPO_ROOT}/artifacts/keys/client1.pub")"

# экранируем для sed
SERVER_PRIV="$(escape "${SERVER_PRIV_RAW}")"
SERVER_PUB="$(escape "${SERVER_PUB_RAW}")"
CLIENT1_PRIV="$(escape "${CLIENT1_PRIV_RAW}")"
CLIENT1_PUB="$(escape "${CLIENT1_PUB_RAW}")"
SERVER_ADDRESS_ESC="$(escape "${SERVER_ADDRESS}")"
LISTEN_PORT_ESC="$(escape "${LISTEN_PORT}")"
CLIENT1_ADDRESS_ESC="$(escape "${CLIENT1_ADDRESS}")"
DNS_ESC="$(escape "${DNS}")"
SERVER_PUBLIC_ENDPOINT_ESC="$(escape "${SERVER_PUBLIC_ENDPOINT}")"
ALLOWED_SUBNETS_ESC="$(escape "${ALLOWED_SUBNETS}")"

mkdir -p "${REPO_ROOT}/artifacts/clients"

# --- сервер ---
sed -e "s|{{SERVER_ADDRESS}}|${SERVER_ADDRESS_ESC}|g" \
    -e "s|{{LISTEN_PORT}}|${LISTEN_PORT_ESC}|g" \
    -e "s|{{SERVER_PRIVATE_KEY}}|${SERVER_PRIV}|g" \
  "${SCRIPT_DIR}/templates/wg0.server.conf.tpl" > /tmp/wg0.server.conf

sudo install -m 600 /tmp/wg0.server.conf /etc/wireguard/wg0.conf
rm -f /tmp/wg0.server.conf
echo "[OK] Rendered /etc/wireguard/wg0.conf"

# --- клиент ---
sed -e "s|{{CLIENT_ADDRESS}}|${CLIENT1_ADDRESS_ESC}|g" \
    -e "s|{{CLIENT_PRIVATE_KEY}}|${CLIENT1_PRIV}|g" \
    -e "s|{{SERVER_PUBLIC_KEY}}|${SERVER_PUB}|g" \
    -e "s|{{SERVER_PUBLIC_ENDPOINT}}|${SERVER_PUBLIC_ENDPOINT_ESC}|g" \
    -e "s|{{LISTEN_PORT}}|${LISTEN_PORT_ESC}|g" \
    -e "s|{{ALLOWED_SUBNETS}}|${ALLOWED_SUBNETS_ESC}|g" \
  "${SCRIPT_DIR}/templates/wg0.client.conf.tpl" > "${REPO_ROOT}/artifacts/clients/wg0.client1.conf"

chmod 600 "${REPO_ROOT}/artifacts/clients/wg0.client1.conf"
echo "[OK] Rendered ${REPO_ROOT}/artifacts/clients/wg0.client1.conf"
