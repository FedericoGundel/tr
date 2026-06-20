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

## Conectarlo a n8n (opcional, más adelante)

Este bot puede reenviar cada mensaje a un webhook de n8n (HTTP POST) y enviar lo
que n8n responda. Si querés ese flujo, avisá y agregamos esa integración.
