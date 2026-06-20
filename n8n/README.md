# n8n local + WhatsApp Cloud API

Setup para correr **n8n** en tu máquina con Docker y, opcionalmente, conectarlo a
**WhatsApp Cloud API** mediante un túnel HTTPS (Meta exige webhooks HTTPS).

## Requisitos

- [Docker](https://docs.docker.com/get-docker/) con Docker Compose v2 (`docker compose`).

## 1. Uso básico (solo n8n local)

```bash
cd n8n
cp .env.example .env      # opcional: ajustá la zona horaria
./start.sh                # o: docker compose up -d
```

Abrí **http://localhost:5678** y creá tu cuenta de administrador.

Para apagarlo: `docker compose down` (tus datos quedan en el volumen `n8n_data`).

## 2. Conectar WhatsApp Cloud API (con túnel)

En local no tenés una URL HTTPS pública, así que usamos **cloudflared** para
crear un túnel gratis hacia n8n.

```bash
./start.sh tunnel
```

Esto levanta n8n + el túnel e imprime una URL tipo
`https://xxxx.trycloudflare.com`. Luego:

1. Pegá esa URL en `WEBHOOK_URL` dentro de `.env` (con `/` al final) y reiniciá:
   ```bash
   ./start.sh tunnel
   ```
2. En **n8n**: importá el workflow de ejemplo
   `workflows/whatsapp-echo.example.json` (menú → Import from File) y activalo.
   Copiá la **Production URL** del nodo Webhook (será
   `https://xxxx.trycloudflare.com/webhook/whatsapp`).
3. En **Meta** ([developers.facebook.com](https://developers.facebook.com)):
   - Creá una app **Business** y agregá el producto **WhatsApp**.
   - En **WhatsApp → Configuration → Webhook** poné:
     - **Callback URL:** la Production URL de n8n.
     - **Verify token:** un texto que inventes.
     - Suscribite al campo **messages**.
   - En **API Setup** copiá el **Temporary access token** y el **Phone number ID**,
     y agregá tu número como destinatario de prueba.

> Nota: la URL gratuita de `trycloudflare.com` cambia cada vez que reiniciás el
> túnel. Para algo estable necesitás un túnel con cuenta de Cloudflare o un VPS
> con dominio.

## 3. Token de WhatsApp para el workflow de ejemplo

El workflow lee el token desde la variable de entorno `WHATSAPP_TOKEN`.
Agregala al servicio `n8n` en `docker-compose.yml` (o en `.env` + el compose):

```yaml
    environment:
      - WHATSAPP_TOKEN=EAAG...tu_token
```

Alternativamente, reemplazá el nodo HTTP Request por el nodo nativo
**WhatsApp Business Cloud** y cargá las credenciales desde la UI de n8n.

## Archivos

| Archivo | Para qué sirve |
|---|---|
| `docker-compose.yml` | Define n8n + túnel cloudflared (perfil `tunnel`). |
| `.env.example` | Variables de configuración (copiar a `.env`). |
| `start.sh` | Atajo para levantar n8n con o sin túnel. |
| `workflows/whatsapp-echo.example.json` | Workflow de ejemplo: recibe y responde un mensaje. |

## Recordatorios de WhatsApp Cloud API

- El token temporal dura **24 h**. Para producción generá un token permanente con
  un **System User** (Business Settings → System Users).
- Fuera de la ventana de 24 h de conversación solo podés iniciar con
  **plantillas (templates)** aprobadas, no con texto libre.
