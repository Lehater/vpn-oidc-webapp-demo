#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Включаем IPv4 forwarding (если ещё не включён)
sudo sysctl -w net.ipv4.ip_forward=1 >/dev/null
echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.d/99-wg-forward.conf >/dev/null || true

# Стартуем wg0, если не запущен
if ! systemctl is-active --quiet wg-quick@wg0; then
  sudo systemctl enable --now wg-quick@wg0
fi

# Подхватываем параметры и адрес клиента
source "${SCRIPT_DIR}/server.env"
CLIENT1_ADDR="${CLIENT1_ADDRESS}"

# Читаем публичный ключ клиента из корректного места в репозитории
CLIENT1_PUB="$(cat "${REPO_ROOT}/artifacts/keys/client1.pub")"

# Проверим, существует ли уже такой peer
if sudo wg show wg0 peers | grep -q "${CLIENT1_PUB}"; then
  echo "[OK] Peer уже добавлен: ${CLIENT1_PUB}"
else
  echo "[..] Добавляю peer клиента: ${CLIENT1_PUB} (AllowedIPs ${CLIENT1_ADDR}/32)"
  sudo wg set wg0 peer "${CLIENT1_PUB}" allowed-ips "${CLIENT1_ADDR}/32"
  echo "[OK] Peer добавлен"
fi

# Показ текущего состояния
echo
sudo wg show
echo "[OK] WireGuard up: wg0"
