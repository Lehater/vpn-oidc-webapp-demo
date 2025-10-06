# Решает: клиентский доступ только к подсети VPN
[Interface]
Address = {{CLIENT_ADDRESS}}/32
PrivateKey = {{CLIENT_PRIVATE_KEY}}
DNS = {{DNS}}

[Peer]
PublicKey = {{SERVER_PUBLIC_KEY}}
Endpoint = {{SERVER_PUBLIC_ENDPOINT}}:{{LISTEN_PORT}}
AllowedIPs = {{ALLOWED_SUBNETS}}
PersistentKeepalive = 25
