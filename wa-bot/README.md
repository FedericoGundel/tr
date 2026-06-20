# wa-bot — Bot de WhatsApp en tu línea personal (Termux / Android)

Bot que se vincula a tu WhatsApp **escaneando un QR** (igual que WhatsApp Web),
usando la librería [Baileys](https://github.com/WhiskeySockets/Baileys).
Tu número **sigue funcionando normal** en la app del teléfono.

> ⚠️ **Aviso:** los bots no oficiales van **contra los términos de WhatsApp** y
> existe **riesgo de baneo** del número, sobre todo si envías muchos mensajes o
> spam. Usalo de forma responsable, para uso personal y a bajo volumen.

## Instalación (en Termux)

```bash
# 1. Traé el código (si ya clonaste el repo, hacé git pull)
cd wa-bot

# 2. Instalá las dependencias
npm install

# 3. Arrancá el bot
npm start
```

Al iniciar, aparece un **QR en la terminal**. En tu teléfono andá a:

**WhatsApp → Ajustes → Dispositivos vinculados → Vincular un dispositivo**

y escaneá el QR. Cuando veas `✅ Conectado`, el bot ya responde.

La sesión queda guardada en la carpeta `auth/`, así que la próxima vez no hace
falta escanear de nuevo (solo `npm start`).

## Probarlo

Desde otro teléfono, mandale un mensaje a tu número:
- `ping` → responde `pong`
- `hola` → saludo
- `menu` → lista de comandos
- `hora` → fecha y hora
- `eco hola mundo` → repite "hola mundo"

## Personalizar

Toda la lógica está en la función `handleMessage()` de `index.js`.
Agregá tus propios comandos ahí. Por defecto el bot **ignora los grupos**
(podés quitar ese filtro en `index.js`).

## Tips para que no se corte (Android)

- Dejá **Termux abierto** mientras el bot corre.
- En la notificación de Termux tocá **"Acquire wakelock"** para que Android no
  lo suspenda.
- Para frenarlo: `Ctrl + C`. Para reiniciar: `npm start`.

## Dejarlo corriendo 24/7 en Railway

El teléfono no sirve para algo permanente. Para que el bot quede asociado y
siempre encendido, conviene un host como **Railway** (o Render, Fly.io, un VPS).

### Variables de entorno importantes

| Variable | Para qué |
|---|---|
| `AUTH_DIR` | Carpeta donde se guarda la sesión. **En Railway apuntala a un Volume** (ej: `/data/auth`) para no perder la sesión en cada reinicio. |
| `PAIRING_NUMBER` | Tu número con código de país, solo dígitos (ej: `5493510000000`). Si lo seteás, el bot pide un **código de vinculación** en vez de QR (ideal para servidores sin pantalla). |
| `PORT` | Puerto del healthcheck HTTP (Railway lo setea solo). |

### Pasos en Railway

1. **New Project → Deploy from GitHub repo** → elegí este repo y la branch.
2. En **Settings → Root Directory** poné `wa-bot` (porque el bot está en esa subcarpeta).
3. En **Variables** agregá:
   - `AUTH_DIR` = `/data/auth`
   - `PAIRING_NUMBER` = tu número (ej: `5493510000000`)
4. En **Volumes**, creá un volume y montalo en `/data` (así `auth/` persiste).
5. Deploy. Abrí los **Logs**: vas a ver
   ```
   CODIGO DE VINCULACION: ABCD-1234
   ```
6. En tu WhatsApp: **Dispositivos vinculados → Vincular con número de teléfono**
   → ingresá ese código. Cuando los logs digan `✅ Conectado`, listo.

> Importante: como la sesión queda en el Volume (`/data/auth`), los reinicios y
> redeploys **no** te van a pedir vincular de nuevo. Si alguna vez querés
> reconectar desde cero, borrá el contenido del volume.

> Nota de costo: el plan gratuito de Railway tiene horas/recursos limitados; un
> bot 24/7 probablemente requiera el plan de pago (o usar un VPS barato).

## Conectarlo a n8n (opcional, más adelante)

Este bot puede reenviar cada mensaje a un webhook de n8n (HTTP POST) y enviar lo
que n8n responda. Si querés ese flujo, avisá y agregamos esa integración.
