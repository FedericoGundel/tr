#!/usr/bin/env bash
# Arranque rapido de n8n en local.
#   ./start.sh          -> levanta solo n8n (http://localhost:5678)
#   ./start.sh tunnel   -> levanta n8n + tunel HTTPS (para WhatsApp Cloud API)
set -euo pipefail

cd "$(dirname "$0")"

if [ ! -f .env ]; then
  echo "No existe .env, lo creo desde .env.example..."
  cp .env.example .env
fi

if [ "${1:-}" = "tunnel" ]; then
  echo "Levantando n8n + cloudflared (tunel HTTPS)..."
  docker compose --profile tunnel up -d
  echo
  echo "Esperando la URL publica del tunel..."
  sleep 6
  docker compose logs cloudflared 2>/dev/null | grep -Eo 'https://[a-zA-Z0-9.-]+\.trycloudflare\.com' | tail -1 \
    && echo ">> Pega esa URL en WEBHOOK_URL del .env y reinicia: ./start.sh tunnel" \
    || echo ">> Mira la URL con: docker compose logs cloudflared"
else
  echo "Levantando n8n..."
  docker compose up -d
  echo ">> Abri http://localhost:5678"
fi
