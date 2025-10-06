# Решает: точная модель периметра, серверный туннель на 10.6.0.1/24
[Interface]
Address = {{SERVER_ADDRESS}}/24
ListenPort = {{LISTEN_PORT}}
PrivateKey = {{SERVER_PRIVATE_KEY}}
# Правила маршрутизации/форвардинга вне этого файла настраиваются отдельно (sysctl/ufw)

# Пример первого клиента (опционально, клиенты добавляются командой wg set)
# [Peer]
# PublicKey = {{CLIENT1_PUBLIC_KEY}}
# AllowedIPs = {{CLIENT1_ADDRESS}}/32
