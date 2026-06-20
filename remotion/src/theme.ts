import { loadFont } from "@remotion/fonts";
import { continueRender, delayRender, staticFile } from "remotion";

// Brand palette taken from the real EnerGym app screenshots: a pink→purple
// gradient identity over a dark navy background (women's fitness app).
export const COLORS = {
  background: "#0A0A12",
  backgroundAlt: "#0E0D17",
  surface: "#16141F",
  surfaceAlt: "#211E2E",
  nav: "#1B1A2B",
  pink: "#FF2E93",
  purple: "#A23DE0",
  text: "#FFFFFF",
  textMuted: "#8E8AA0",
  success: "#2FBF71",
  successBg: "#123524",
  warn: "#C9962B",
  warnBg: "#2E2613",
} as const;

// Signature pink→purple gradient used across the app (login button, accents).
export const GRADIENT = `linear-gradient(135deg, ${COLORS.pink} 0%, ${COLORS.purple} 100%)`;

// Montserrat is bundled locally (public/fonts) so rendering works offline,
// without depending on fonts.gstatic.com.
export const fontFamily = "Montserrat";

const weights = ["400", "600", "700", "800", "900"] as const;
const handle = delayRender("Loading Montserrat");
Promise.all(
  weights.map((weight) =>
    loadFont({
      family: fontFamily,
      url: staticFile(`fonts/Montserrat-${weight}.woff2`),
      weight,
    }),
  ),
)
  .then(() => continueRender(handle))
  .catch((err) => {
    console.error("Font load failed", err);
    continueRender(handle);
  });

export const FPS = 30;
