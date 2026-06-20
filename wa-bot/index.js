// Bot de WhatsApp para tu linea personal (vinculacion por QR, como WhatsApp Web).
// Usa Baileys. Tu numero sigue funcionando normal en la app del telefono.
//
// AVISO: usar bots no oficiales va contra los terminos de WhatsApp y hay
// riesgo de baneo del numero, sobre todo si envia muchos mensajes o spam.
// Usalo de forma responsable y para uso personal.

const {
  default: makeWASocket,
  useMultiFileAuthState,
  DisconnectReason,
  fetchLatestBaileysVersion,
} = require("@whiskeysockets/baileys");
const qrcode = require("qrcode-terminal");
const pino = require("pino");
const http = require("http");

// Logger silencioso (Baileys es muy verboso por defecto).
const logger = pino({ level: "silent" });

// Carpeta donde se guarda la sesion. En Railway/host con Volume, apunta
// esta variable al volumen persistente (ej: AUTH_DIR=/data/auth).
const AUTH_DIR = process.env.AUTH_DIR || "auth";

// Si seteas PAIRING_NUMBER (ej: 549351xxxxxxx, solo numeros con codigo de pais),
// el bot pide un CODIGO DE VINCULACION en vez de QR. Ideal para servidores sin
// pantalla (Railway): vinculas desde WhatsApp -> Dispositivos vinculados ->
// "Vincular con numero de telefono" e ingresas el codigo de 8 caracteres.
const PAIRING_NUMBER = (process.env.PAIRING_NUMBER || "").replace(/[^0-9]/g, "");

// Estado de conexion, expuesto por el servidor HTTP de healthcheck.
let connected = false;

async function start() {
  const { state, saveCreds } = await useMultiFileAuthState(AUTH_DIR);
  const { version } = await fetchLatestBaileysVersion();

  const sock = makeWASocket({
    version,
    auth: state,
    logger,
    // markOnlineOnConnect: false evita aparecer "en linea" todo el tiempo.
    markOnlineOnConnect: false,
  });

  // Si usamos codigo de vinculacion y todavia no estamos registrados, pedirlo.
  if (PAIRING_NUMBER && !sock.authState.creds.registered) {
    setTimeout(async () => {
      try {
        const code = await sock.requestPairingCode(PAIRING_NUMBER);
        console.log("\n==============================");
        console.log("  CODIGO DE VINCULACION: " + code);
        console.log("  WhatsApp -> Dispositivos vinculados ->");
        console.log("  'Vincular con numero de telefono' -> ingresa el codigo");
        console.log("==============================\n");
      } catch (e) {
        console.error("No se pudo generar el codigo de vinculacion:", e?.message || e);
      }
    }, 3000);
  }

  // Guarda credenciales cuando cambian.
  sock.ev.on("creds.update", saveCreds);

  // Estado de la conexion + QR.
  sock.ev.on("connection.update", (update) => {
    const { connection, lastDisconnect, qr } = update;

    // Solo mostramos QR si NO estamos usando codigo de vinculacion.
    if (qr && !PAIRING_NUMBER) {
      console.log("\nEscanea este QR con WhatsApp:");
      console.log("(WhatsApp -> Dispositivos vinculados -> Vincular dispositivo)\n");
      qrcode.generate(qr, { small: true });
    }

    if (connection === "open") {
      connected = true;
      console.log("\n✅ Conectado a WhatsApp. El bot esta escuchando mensajes.\n");
    }

    if (connection === "close") {
      const code = lastDisconnect?.error?.output?.statusCode;
      const loggedOut = code === DisconnectReason.loggedOut;
      connected = false;
      console.log("Conexion cerrada.", loggedOut ? "Sesion cerrada." : "Reconectando...");
      if (!loggedOut) start();
      else console.log("Borra la carpeta 'auth' y volve a iniciar para vincular de nuevo.");
    }
  });

  // Mensajes entrantes.
  sock.ev.on("messages.upsert", async ({ messages, type }) => {
    if (type !== "notify") return;

    for (const msg of messages) {
      // Ignorar mensajes propios y vacios.
      if (!msg.message || msg.key.fromMe) continue;

      const from = msg.key.remoteJid;
      // Ignorar grupos (terminan en @g.us). Quitar este filtro si queres que responda en grupos.
      if (from.endsWith("@g.us")) continue;

      const text = (
        msg.message.conversation ||
        msg.message.extendedTextMessage?.text ||
        ""
      ).trim();

      if (!text) continue;
      console.log(`📩 ${from}: ${text}`);

      const reply = handleMessage(text);
      if (reply) {
        await sock.sendMessage(from, { text: reply });
      }
    }
  });
}

// ====== Aca defines la logica del bot ======
// Devolve el texto a responder, o null para no responder.
function handleMessage(text) {
  const lower = text.toLowerCase();

  if (lower === "ping") return "pong 🏓";
  if (lower === "hola" || lower === "buenas") {
    return "¡Hola! Soy un bot 🤖. Escribi *menu* para ver que puedo hacer.";
  }
  if (lower === "menu" || lower === "ayuda") {
    return [
      "📋 *Menu*",
      "- *ping* -> test",
      "- *hora* -> te digo la hora",
      "- *eco <texto>* -> repito lo que digas",
    ].join("\n");
  }
  if (lower === "hora") {
    return "🕒 " + new Date().toLocaleString("es-AR");
  }
  if (lower.startsWith("eco ")) {
    return text.slice(4);
  }

  // Respuesta por defecto (comenta esta linea si no queres que responda a todo).
  return "No entendi 🤔. Escribi *menu* para ver las opciones.";
}

// Mini servidor HTTP: hosts como Railway esperan que el proceso escuche en un
// puerto y lo usan como healthcheck. Tambien sirve para ver el estado.
const PORT = process.env.PORT || 3000;
http
  .createServer((req, res) => {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ ok: true, connected }));
  })
  .listen(PORT, () => console.log(`HTTP healthcheck en puerto ${PORT}`));

start().catch((err) => console.error("Error al iniciar:", err));
