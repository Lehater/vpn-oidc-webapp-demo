#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# Решает: идемпотентный рендер wg0.conf из шаблонов
source ./server.env

# Загрузка ключей
SERVER_PRIV=$(cat ../../artifacts/keys/server.key)
SERVER_PUB=$(cat ../../artifacts/keys/server.pub)
CLIENT1_PRIV=$(cat ../../artifacts/keys/client1.key)
CLIENT1_PUB=$(cat ../../artifacts/keys/client1.pub)

mkdir -p ../../artifacts/clients

# Рендер сервера
sed -e "s/{{SERVER_ADDRESS}}/${SERVER_ADDRESS}/g" \
    -e "s/{{LISTEN_PORT}}/${LISTEN_PORT}/g" \
    -e "s/{{SERVER_PRIVATE_KEY}}/${SERVER_PRIV}/g" \
  templates/wg0.server.conf.tpl > /tmp/wg0.server.conf

sudo install -m 600 /tmp/wg0.server.conf /etc/wireguard/wg0.conf
rm -f /tmp/wg0.server.conf
echo "[OK] Rendered /etc/wireguard/wg0.conf"

# Рендер клиента 1
sed -e "s/{{CLIENT_ADDRESS}}/${CLIENT1_ADDRESS}/g" \
    -e "s/{{CLIENT_PRIVATE_KEY}}/${CLIENT1_PRIV}/g" \
    -e "s/{{DNS}}/${DNS}/g" \
    -e "s/{{SERVER_PUBLIC_KEY}}/${SERVER_PUB}/g" \
    -e "s/{{SERVER_PUBLIC_ENDPOINT}}/${SERVER_PUBLIC_ENDPOINT}/g" \
    -e "s/{{LISTEN_PORT}}/${LISTEN_PORT}/g" \
    -e "s/{{ALLOWED_SUBNETS}}/${ALLOWED_SUBNETS}/g" \
  templates/wg0.client.conf.tpl > ../../artifacts/clients/wg0.client1.conf

chmod 600 ../../artifacts/clients/wg0.client1.conf
echo "[OK] Rendered artifacts/clients/wg0.client1.conf"
