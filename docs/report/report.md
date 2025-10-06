---
title: "Демо: Web-приложение за VPN + OIDC (Keycloak)"
author: "ФИО"
date: "YYYY-MM-DD"
---

# Введение (цель работы)
Цель: создать простое веб-приложение (>1 страницы), обеспечить доступ **только через VPN**, интегрировать авторизацию по **OAuth2/OIDC** (Keycloak внутри периметра).

# Как устроено веб-приложение
- Архитектура: см. диаграмму C4 (docs/diagrams/c4-variant-b.puml).
- Периметр: WireGuard (10.6.0.0/24), Nginx (TLS, bind к wg0), UFW (deny на eth0, allow на wg0).
- Приложение: Node/Express, `openid-client`, защищённый `/profile` (Authorization Code Flow).

Ключевые решения:
- Привязка Nginx к IP wg0 → исключён доступ вне VPN.
- Secure/Lax cookie → защита сессии.
- OIDC state/nonce → защита от CSRF/реиграций.

# Настройка работы VPN
Скриншоты:
1. `wg0.conf` сервера и клиента (ключи скрыть).
2. `wg show` на сервере (Peers/Handshake).
3. `curl -k https://app.vpn.local` без VPN → **недоступно**.
4. `curl -k https://app.vpn.local` с VPN → **OK**.

# Интеграция авторизации (OIDC)
Скриншоты:
1. Страница логина Keycloak (`sso.vpn.local:8443`).
2. Успешный `/profile` (claims).
3. Настройки клиента в Keycloak (Redirect URI = `https://app.vpn.local/oidc/callback`).

# Выводы и сложности
- Получилось: сетевой периметр + прикладная аутентификация.
- Сложности: доверие самоподписанному сертификату; точное совпадение Redirect URI.
- Улучшения: MFA (Keycloak), RBAC по группам, Ansible/Terraform для идемпотентного развёртывания.
