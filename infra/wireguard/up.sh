#!/usr/bin/env bash
set -euo pipefail

# Решает: корректный запуск wg0 + включение форвардинга
if ! command -v wg-quick >/dev/null; then
  echo "wg-quick not found. Install wireguard." >&2
  exit 1
fi

# Включаем IPv4 форвардинг (нужно для маршрутизации при необходимости)
sudo sysctl -w net.ipv4.ip_forward=1
echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.d/99-wg-forward.conf >/dev/null

# Запускаем wg0
sudo systemctl enable --now wg-quick@wg0

# Добавляем первого клиента в сервер (если не добавлен)
SERVER_PUB=$(sudo cat /etc/wireguard/wg0.conf | grep -E '^PrivateKey' || true)
if [[ -n "$SERVER_PUB" ]]; then
  # no-op: сервер уже знает свой ключ
  :
fi

# Добавим Peer клиента явно
CLIENT1_PUB=$(cat ../../artifacts/keys/client1.pub)
CLIENT1_ADDR=$(grep '^CLIENT1_ADDRESS=' infra/wireguard/server.env | cut -d= -f2)
sudo wg set wg0 peer "$CLIENT1_PUB" allowed-ips "${CLIENT1_ADDR}/32" || true

# Показ состояния
sudo wg show
echo "[OK] WireGuard up: wg0"
