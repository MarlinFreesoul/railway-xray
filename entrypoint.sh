#!/bin/sh
set -e
: "${UUID:?UUID env required}"
WS_PATH="${WS_PATH:-/ray}"
LISTEN_PORT="${PORT:-8080}"
mkdir -p /usr/local/etc/xray
cat > /usr/local/etc/xray/config.json <<EOF2
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": ${LISTEN_PORT},
      "protocol": "vless",
      "settings": {
        "clients": [ { "id": "${UUID}" } ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": { "path": "${WS_PATH}" }
      }
    }
  ],
  "outbounds": [ { "protocol": "freedom", "tag": "direct" } ]
}
EOF2
echo "xray starting on port ${LISTEN_PORT}, path ${WS_PATH}"
exec xray run -config /usr/local/etc/xray/config.json
