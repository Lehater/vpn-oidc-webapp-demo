#!/usr/bin/env bash
set -euo pipefail

APP_HOST="${APP_HOST:-app.vpn.local}"
SSO_HOST="${SSO_HOST:-sso.vpn.local}"

echo "[1] Проверка доступности без VPN (должно быть НЕдоступно)"
if curl -k --connect-timeout 3 "https://${APP_HOST}/" >/dev/null 2>&1; then
  echo "ERROR: ${APP_HOST} доступен без VPN — нарушение периметра"
  exit 1
else
  echo "ОК: без VPN недоступно"
fi

echo "[2] Подключите VPN и нажмите Enter"
read -r

echo "[3] Проверка доступности с VPN"
curl -k --fail "https://${APP_HOST}/" >/dev/null && echo "ОК: главная открывается" || { echo "ERROR: главная недоступна"; exit 1; }

echo "[4] OIDC редирект на Keycloak"
# Ожидаем редирект на /authorize. Проверим заголовки ответа без следования редиректам.
if curl -k -I -s "https://${APP_HOST}/profile" | grep -qi "location: https://${SSO_HOST}"; then
  echo "ОК: редирект на ${SSO_HOST} при обращении к /profile"
else
  echo "WARN: не увидели редирект (проверьте приложение/сессии)"
fi

echo "[OK] Клиентские проверки завершены"
