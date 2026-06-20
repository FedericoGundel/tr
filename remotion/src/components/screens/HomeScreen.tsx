import { AbsoluteFill } from "remotion";
import { COLORS, GRADIENT, fontFamily } from "../../theme";
import { BottomNav, StatusBar } from "./parts";

const DAYS = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"];

const DayCircle: React.FC<{
  label: string;
  state: "done" | "rest" | "today";
}> = ({ label, state }) => {
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: 10,
      }}
    >
      <div
        style={{
          width: 64,
          height: 64,
          borderRadius: "50%",
          background: state === "done" ? GRADIENT : COLORS.surfaceAlt,
          border:
            state === "today" ? `3px solid ${COLORS.pink}` : "3px solid transparent",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontSize: 26,
        }}
      >
        {state === "done" ? (
          <span style={{ color: COLORS.text, fontWeight: 900 }}>✓</span>
        ) : state === "today" ? (
          <span
            style={{
              width: 14,
              height: 14,
              borderRadius: "50%",
              backgroundColor: COLORS.pink,
            }}
          />
        ) : (
          <span style={{ opacity: 0.6 }}>🛏️</span>
        )}
      </div>
      <span
        style={{
          color: state === "today" ? COLORS.pink : COLORS.textMuted,
          fontSize: 20,
          fontWeight: 700,
        }}
      >
        {label}
      </span>
    </div>
  );
};

const Achievement: React.FC<{
  icon: string;
  value: string;
  label: string;
}> = ({ icon, value, label }) => (
  <div
    style={{
      flex: 1,
      backgroundColor: COLORS.surface,
      borderRadius: 22,
      padding: "22px 18px",
      display: "flex",
      flexDirection: "column",
      gap: 8,
    }}
  >
    <span style={{ fontSize: 30 }}>{icon}</span>
    <span style={{ color: COLORS.text, fontSize: 38, fontWeight: 900 }}>
      {value}
    </span>
    <span style={{ color: COLORS.textMuted, fontSize: 20 }}>{label}</span>
  </div>
);

// Recreation of the EnerGym "Hoy" (home) view.
export const HomeScreen: React.FC = () => {
  return (
    <AbsoluteFill style={{ fontFamily, backgroundColor: COLORS.background }}>
      <StatusBar />
      <div
        style={{
          flex: 1,
          padding: "20px 40px 140px",
          display: "flex",
          flexDirection: "column",
          gap: 34,
        }}
      >
        {/* Header */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: 18 }}>
            <div
              style={{
                width: 64,
                height: 64,
                borderRadius: "50%",
                background: GRADIENT,
                color: COLORS.text,
                fontSize: 26,
                fontWeight: 900,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
              }}
            >
              LG
            </div>
            <span style={{ color: COLORS.text, fontSize: 34, fontWeight: 800 }}>
              ¡Hola, Laura! 🏋️
            </span>
          </div>
          <div style={{ display: "flex", gap: 18, fontSize: 28 }}>
            <span>🌙</span>
          </div>
        </div>

        {/* Today's routine card */}
        <div
          style={{
            background:
              "linear-gradient(135deg, #2A1030 0%, #14121E 100%)",
            border: `1px solid ${COLORS.pink}66`,
            borderRadius: 26,
            padding: 34,
            display: "flex",
            flexDirection: "column",
            gap: 12,
          }}
        >
          <span
            style={{
              color: COLORS.pink,
              fontSize: 22,
              fontWeight: 800,
              letterSpacing: 1,
            }}
          >
            TU RUTINA DE HOY · SÁB 20/06
          </span>
          <span style={{ color: COLORS.text, fontSize: 46, fontWeight: 900 }}>
            Día de descanso 🛌
          </span>
          <span style={{ color: COLORS.textMuted, fontSize: 26 }}>
            Hoy no tenés rutina asignada. ¡Aprovechá para recuperar!
          </span>
        </div>

        {/* Week */}
        <div style={{ display: "flex", flexDirection: "column", gap: 20 }}>
          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
            }}
          >
            <span style={{ color: COLORS.text, fontSize: 34, fontWeight: 800 }}>
              Tu semana
            </span>
            <span style={{ color: COLORS.pink, fontSize: 24, fontWeight: 700 }}>
              Ver completo →
            </span>
          </div>
          <div style={{ display: "flex", justifyContent: "space-between" }}>
            {DAYS.map((d, i) => (
              <DayCircle
                key={d}
                label={d}
                state={i === 0 ? "done" : i === 5 ? "today" : "rest"}
              />
            ))}
          </div>
        </div>

        {/* Achievements */}
        <div style={{ display: "flex", flexDirection: "column", gap: 20 }}>
          <span style={{ color: COLORS.text, fontSize: 34, fontWeight: 800 }}>
            Logros rápidos
          </span>
          <div style={{ display: "flex", gap: 16 }}>
            <Achievement icon="🔥" value="0 días" label="Racha actual" />
            <Achievement icon="🏅" value="1" label="Este mes" />
            <Achievement icon="⏱️" value="0 hs" label="Tiempo total" />
          </div>
        </div>
      </div>
      <BottomNav active="hoy" />
    </AbsoluteFill>
  );
};
