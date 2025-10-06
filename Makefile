SHELL := /bin/bash

.PHONY: compose-up compose-down tls keycloak hosts docker-user

compose-up:
	docker compose up -d --build

compose-down:
	docker compose down -v

tls:
	chmod +x infra/nginx/tls/make-self-signed.sh
	CN=app.vpn.local ./infra/nginx/tls/make-self-signed.sh

keycloak:
	@echo "Keycloak импортирует realm автоматически при старте благодаря --import-realm"

hosts:
	@echo "Добавьте на КЛИЕНТЕ:"
	@echo "10.6.0.1 app.vpn.local sso.vpn.local"

docker-user:
	chmod +x infra/firewall/docker-user.sh
	./infra/firewall/docker-user.sh

wg.genkeys:
	chmod +x infra/wireguard/genkeys.sh
	infra/wireguard/genkeys.sh

wg.render:
	chmod +x infra/wireguard/render.sh
	infra/wireguard/render.sh

wg.up:
	chmod +x infra/wireguard/up.sh
	infra/wireguard/up.sh

wg.down:
	chmod +x infra/wireguard/down.sh
	infra/wireguard/down.sh

ufw.apply:
	chmod +x infra/firewall/ufw.sh
	EXT_IF=eth0 WG_IF=wg0 infra/firewall/ufw.sh

docker-user:
	chmod +x infra/firewall/docker-user.sh
	infra/firewall/docker-user.sh

# TLS с SAN
tls.san:
	chmod +x infra/nginx/tls/make-san-cert.sh
	./infra/nginx/tls/make-san-cert.sh

# Проверки
check.server:
	chmod +x scripts/check_server.sh
	./scripts/check_server.sh

check.client:
	chmod +x scripts/check_client.sh
	./scripts/check_client.sh