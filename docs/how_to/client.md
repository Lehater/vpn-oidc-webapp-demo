Только **клиентская** сторона. Ниже — полный чек-лист запуска «Вариант B» для клиента (Linux/macOS/Windows). Цель: подключиться к VPN, видеть `app.vpn.local`/`sso.vpn.local` **только** через туннель и пройти OIDC-логин.

---

# 1) Предпосылки на клиенте

* Установлен WireGuard:

  * **Linux**: `sudo apt install wireguard` (или менеджер дистрибутива)
  * **macOS**: WireGuard из App Store / brew (`brew install --cask wireguard`)
  * **Windows**: WireGuard MSI с официального сайта
* Любой современный браузер (Chrome/Edge/Firefox/Safari)

---

# 2) Получить клиентский конфиг

От сервера выдают файл `wg0.client1.conf`.

**Способы:**

* `scp` (Linux/macOS):

  ```bash
  scp user@SERVER:/path/to/repo/artifacts/clients/wg0.client1.conf .
  ```
* В Windows — скачайте по WinSCP/SSH, сохраните как `wg0.conf`.

> Критично: не правьте ключи внутри — они уже сгенерированы. Разрешение диапазона по умолчанию: `AllowedIPs = 10.6.0.0/24`. Если нужен **полный** трафик через VPN — меняют на `0.0.0.0/0, ::/0` (обычно не нужно для этой задачи).

---

# 3) Добавить hosts-записи (имена → IP wg0 сервера)

На **клиенте** пропишите:

```
10.6.0.1 app.vpn.local sso.vpn.local
```

Где править:

* **Linux**: `/etc/hosts` (через `sudo nano /etc/hosts`)
* **macOS**: `/etc/hosts`
* **Windows**: `C:\Windows\System32\drivers\etc\hosts` (запуск блокнота от администратора)

> Без этого браузер не попадёт на VPN-адреса по именам.

---

# 4) Подключиться к VPN

## Вариант A — GUI (рекомендуется для macOS/Windows)

1. Откройте WireGuard.
2. `Add Tunnel` → `Import from file` → выберите `wg0.client1.conf`.
3. Нажмите `Activate / Connect`.

## Вариант B — CLI (Linux)

```bash
sudo wg-quick up ./wg0.client1.conf
# или переместите в /etc/wireguard/wg0.conf и:
# sudo wg-quick up wg0
```

**Проверка:**

* Статус/handshake:

  * **Linux**: `sudo wg show`
  * **macOS/Windows**: статус в GUI
* Пинг сервера по VPN:
  `ping 10.6.0.1` (Linux/macOS) / `ping 10.6.0.1 -t` (Windows)

---

# 5) Доверить самоподписанный сертификат (необязательно, но удобно)

Сайт открывается по HTTPS с self-signed. Можно:

* Просто игнорировать предупреждение (нажать «Продолжить»).
* Или добавить сертификат `app.crt` в «доверенные корневые» (если админ-права есть). Это уберёт предупреждение.

---

# 6) Быстрые smoke-тесты доступа (клиент)

## 6.1 Без VPN (должно быть НЕДОСТУПНО)

Отключите туннель и выполните:

```bash
curl -k --connect-timeout 3 https://app.vpn.local/ || echo "OK: недоступно без VPN"
```

Ожидание: **ошибка соединения/таймаут**.

## 6.2 С VPN (должно быть доступно)

Включите туннель:

```bash
curl -k https://app.vpn.local/ | head -n1
# Должен вернуться HTML заголовок главной страницы
```

## 6.3 Проверка редиректа на OIDC (Keycloak)

```bash
curl -k -I https://app.vpn.local/profile | grep -i location
# Ожидаем Location: https://sso.vpn.local:8443/...
```

---

# 7) Проверка в браузере (клиент)

1. Откройте `https://app.vpn.local/` → при self-signed подтвердите вход.
2. Перейдите на `Profile` → редирект на `https://sso.vpn.local:8443`.
3. Введите тестовые учётные данные (например, `test1` / `Passw0rd!`).
4. После логина вернёт в `https://app.vpn.local/profile` с JSON-claims.

**Критерий успеха:** `/profile` показывает профиль (email/subject), главная доступна, без VPN — недоступно.

---

# 8) Типичные проблемы на клиенте и как починить

* **`app.vpn.local` не открывается с VPN**

  * Проверьте `/etc/hosts` (Windows — файл без расширения, сохранять в ANSI/UTF-8 без BOM).
  * Сбросьте DNS-кэш:

    * **Windows**: `ipconfig /flushdns`
    * **macOS**: `sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder`
    * **Linux** (systemd-resolved): `sudo resolvectl flush-caches`
  * Проверьте, что туннель активен (WireGuard GUI/`sudo wg show`) и `AllowedIPs` включает `10.6.0.0/24`.

* **Браузер помнит старый HSTS/сертификат**

  * Откройте в другом браузере/профиле или очистите HSTS для домена.
  * Используйте `curl -k` для диагностики (обходит валидность сертификата).

* **OIDC не доходит до логина**

  * Проверьте редирект заголовком: `curl -k -I https://app.vpn.local/profile`.
  * Если редиректа нет — возможно сессия в приложении «залипла»: откройте `https://app.vpn.local/logout`, затем снова `Profile`.

* **`ERR_CONNECTION_TIMED_OUT` даже с VPN**

  * Проверьте, что сервер действительно слушает только на `10.6.0.1:443/8443` и ваш туннель видит этот IP (`ping 10.6.0.1`).
  * Если `ping` не идёт — проверьте на сервере, что ваш Peer добавлен (админ сервера: `sudo wg show`).

---

# 9) Отключение VPN

* **GUI**: `Deactivate` в WireGuard.
* **CLI (Linux)**:

  ```bash
  sudo wg-quick down wg0
  ```

> После отключения `https://app.vpn.local` снова **не должен** открываться — это ваш экспресс-тест «только через VPN».

---

# 10) Мини-чек-лист клиента (для отчёта)

* Скрин WireGuard-клиента: `Connected`, адрес `10.6.0.2/32`.
* Содержимое `/etc/hosts` с записью `10.6.0.1 app.vpn.local sso.vpn.local`.
* Консоль `curl -k -I https://app.vpn.local/profile` с `Location: https://sso.vpn.local:8443/...`.
* Скрины браузера: главная → логин Keycloak → профиль.

---

Если хочешь — дам «portable» скрипт `check_client.sh` под Linux/macOS, который автоматизирует пункты 6.1–6.3 и выводит понятный verdict (у нас он уже есть; можно просто скопировать и запускать локально).
