#!/usr/bin/env bash
set -euo pipefail

# Разрешить входящие в контейнеры только со стороны wg0
sudo iptables -C DOCKER-USER -i wg0 -j RETURN 2>/dev/null || sudo iptables -I DOCKER-USER -i wg0 -j RETURN
# Всё прочее — отрубить
sudo iptables -C DOCKER-USER -j DROP 2>/dev/null || sudo iptables -A DOCKER-USER -j DROP

echo "[OK] DOCKER-USER rules applied: allow from wg0 only, drop others."
