import { AbsoluteFill } from "remotion";
import { COLORS, GRADIENT, fontFamily } from "../../theme";
import { BrandLogo } from "../BrandLogo";
import { StatusBar } from "./parts";

// Recreation of the EnerGym login view.
export const LoginScreen: React.FC = () => {
  return (
    <AbsoluteFill
      style={{
        fontFamily,
        background: `linear-gradient(180deg, #1A0E22 0%, ${COLORS.background} 70%)`,
      }}
    >
      <StatusBar />
      <div
        style={{
          flex: 1,
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          padding: "30px 40px 0",
          gap: 22,
        }}
      >
        <BrandLogo size={150} />
        <span
          style={{ color: COLORS.textMuted, fontSize: 30, fontWeight: 500 }}
        >
          Entrená. Crecé. Superáte.
        </span>

        <div
          style={{
            marginTop: 18,
            width: "100%",
            backgroundColor: COLORS.surface,
            borderRadius: 30,
            padding: 40,
            display: "flex",
            flexDirection: "column",
            gap: 22,
          }}
        >
          <span style={{ color: COLORS.text, fontSize: 42, fontWeight: 800 }}>
            Bienvenida de vuelta
          </span>

          <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
            <span
              style={{
                color: COLORS.textMuted,
                fontSize: 22,
                fontWeight: 700,
                letterSpacing: 1,
              }}
            >
              EMAIL
            </span>
            <div
              style={{
                border: `2px solid ${COLORS.pink}`,
                borderRadius: 16,
                padding: "22px 24px",
                color: COLORS.textMuted,
                fontSize: 26,
              }}
            >
              tu@email.com
            </div>
          </div>

          <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
            <span
              style={{
                color: COLORS.textMuted,
                fontSize: 22,
                fontWeight: 700,
                letterSpacing: 1,
              }}
            >
              CONTRASEÑA
            </span>
            <div
              style={{
                backgroundColor: COLORS.surfaceAlt,
                borderRadius: 16,
                padding: "22px 24px",
                color: COLORS.textMuted,
                fontSize: 26,
                display: "flex",
                justifyContent: "space-between",
                alignItems: "center",
              }}
            >
              <span style={{ letterSpacing: 4 }}>••••••••</span>
              <span>👁️</span>
            </div>
          </div>

          <div
            style={{
              background: GRADIENT,
              borderRadius: 18,
              padding: "24px 0",
              textAlign: "center",
              color: COLORS.text,
              fontSize: 30,
              fontWeight: 800,
              marginTop: 6,
            }}
          >
            Ingresar
          </div>
          <span
            style={{
              color: COLORS.pink,
              fontSize: 24,
              fontWeight: 600,
              textAlign: "center",
            }}
          >
            ¿Olvidaste tu contraseña?
          </span>
        </div>
      </div>
    </AbsoluteFill>
  );
};
