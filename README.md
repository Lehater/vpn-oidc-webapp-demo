# vpn-oidc-webapp-demo

Веб-приложение за VPN (WireGuard), доступ только через wg0. Авторизация — OIDC (Keycloak в Docker). Реверс-прокси Nginx (в Docker) публикуется **только** на IP wg0 `10.6.0.1`.

## Быстрый старт

### 0) Предпосылки
- Сервер: Ubuntu 22.04+, публичный IP.
- WireGuard на сервере (wg0 = 10.6.0.1) и клиенте (10.6.0.2).
- На клиенте `/etc/hosts`:
10.6.0.1 app.vpn.local sso.vpn.local


### 1) TLS (SAN на app/sso)
```bash
make tls.san
```
2) Правила DOCKER-USER (страховка против обхода UFW)

```
make docker-user
```
3) Запуск стека

```export OIDC_CLIENT_SECRET=changeme
export SESSION_SECRET=please_change_me
docker compose up -d --build
```
4) Проверка периметра
На сервере:

```make check.server```
На клиенте:

```make check.client```

5) Тест логина
Откройте https://app.vpn.local/ → Profile → редирект в Keycloak.

Логин: test1 / Passw0rd! → возврат в /profile.

Важные замечания
Nginx публикуется только на 10.6.0.1 (wg0). Это — ключ к «только через VPN».

App/Keycloak не публикуются наружу.

Для продакшна замените самоподписанный cert и секреты. Добавьте MFA/RBAC в Keycloak.


---

(Опционально) nftables вместо iptables

Если у вас `nft` по умолчанию: добавьте эквивалент `DOCKER-USER`. Главное — **сохранить смысл**: пропускать во внутренние docker-цепочки только трафик, пришедший с `wg0`.

---
