#!/usr/bin/env bash
set -euo pipefail

# Решает: запрет 80/443 на внешнем интерфейсе, разрешение только на wg0, базовые allow
EXT_IF="${EXT_IF:-eth0}"   # переопредели, если нужно
WG_IF="${WG_IF:-wg0}"

sudo ufw --force reset

# Политики по умолчанию: всё входящее запрещено
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Разрешаем SSH и WireGuard
sudo ufw allow 22/tcp
sudo ufw allow 51820/udp

# Запрещаем HTTP/HTTPS на внешнем iface
sudo ufw deny in on "${EXT_IF}" to any port 80 proto tcp
sudo ufw deny in on "${EXT_IF}" to any port 443 proto tcp

# Разрешаем HTTPS на wg0 (для app и sso через nginx)
sudo ufw allow in on "${WG_IF}" to any port 443 proto tcp
sudo ufw allow in on "${WG_IF}" to any port 8443 proto tcp

sudo ufw --force enable
sudo ufw status verbose
echo "[OK] UFW applied (deny 80/443 on ${EXT_IF}, allow 443/8443 on ${WG_IF})"
