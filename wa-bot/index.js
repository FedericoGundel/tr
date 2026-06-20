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

// Logger silencioso (Baileys es muy verboso por defecto).
const logger = pino({ level: "silent" });

async function start() {
  // Guarda la sesion en ./auth para no tener que escanear el QR cada vez.
  const { state, saveCreds } = await useMultiFileAuthState("auth");
  const { version } = await fetchLatestBaileysVersion();

  const sock = makeWASocket({
    version,
    auth: state,
    logger,
    // markOnlineOnConnect: false evita aparecer "en linea" todo el tiempo.
    markOnlineOnConnect: false,
  });

  // Guarda credenciales cuando cambian.
  sock.ev.on("creds.update", saveCreds);

  // Estado de la conexion + QR.
  sock.ev.on("connection.update", (update) => {
    const { connection, lastDisconnect, qr } = update;

    if (qr) {
      console.log("\nEscanea este QR con WhatsApp:");
      console.log("(WhatsApp -> Dispositivos vinculados -> Vincular dispositivo)\n");
      qrcode.generate(qr, { small: true });
    }

    if (connection === "open") {
      console.log("\n✅ Conectado a WhatsApp. El bot esta escuchando mensajes.\n");
    }

    if (connection === "close") {
      const code = lastDisconnect?.error?.output?.statusCode;
      const loggedOut = code === DisconnectReason.loggedOut;
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

start().catch((err) => console.error("Error al iniciar:", err));
