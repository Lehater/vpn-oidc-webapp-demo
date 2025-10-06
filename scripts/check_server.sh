#!/usr/bin/env bash
set -euo pipefail

WG_IF="${WG_IF:-wg0}"
WG_IP="$(ip -4 addr show ${WG_IF} | awk '/inet /{print $2}' | cut -d/ -f1)"
EXT_IF="${EXT_IF:-$(ip route get 1.1.1.1 | awk '{print $5; exit}')}"
EXT_IP="$(ip -4 addr show ${EXT_IF} | awk '/inet /{print $2}' | cut -d/ -f1)"

echo "WG_IF=${WG_IF} WG_IP=${WG_IP} | EXT_IF=${EXT_IF} EXT_IP=${EXT_IP}"

echo "[1] Проверка LISTEN сокетов..."
ss -ltnp | grep -E '(:443|:8443)' || { echo "Нет слушающих портов 443/8443 — ERROR"; exit 1; }

echo "[2] Проверка биндинга на ${WG_IP}..."
ss -ltn | awk '{print $4}' | grep -E "${WG_IP}:443|${WG_IP}:8443" >/dev/null \
  && echo "ОК: 443/8443 слушаются на ${WG_IP}" \
  || { echo "ERROR: 443/8443 не привязаны к ${WG_IP}"; exit 1; }

echo "[3] Проверка отсутствия биндинга на ${EXT_IP}..."
if ss -ltn | awk '{print $4}' | grep -qE "${EXT_IP}:443|${EXT_IP}:8443"; then
  echo "ERROR: есть слушатель на внешнем интерфейсе ${EXT_IP}"
  exit 1
else
  echo "ОК: на ${EXT_IP} нет 443/8443"
fi

echo "[4] UFW статус (ожидается deny на ${EXT_IF} для 80/443, allow на ${WG_IF} для 443/8443)"
sudo ufw status verbose || true

echo "[5] DOCKER-USER (ожидается allow wg0, drop others)"
sudo iptables -S DOCKER-USER || true

echo "[OK] Серверные проверки завершены"
