import { AbsoluteFill } from "remotion";
import { COLORS, GRADIENT, fontFamily } from "../../theme";
import { BottomNav, Chip, StatusBar } from "./parts";

const WEEK_DAYS = [
  { l: "L", n: "15" },
  { l: "M", n: "16" },
  { l: "X", n: "17" },
  { l: "J", n: "18" },
  { l: "V", n: "19" },
  { l: "S", n: "20" },
];

type Routine = {
  day: string;
  title: string;
  status: { label: string; rest?: boolean };
  chips: { label: string; kind: "level" | "time" | "muscle" | "muscle2" }[];
};

const ROUTINES: Routine[] = [
  {
    day: "LUNES · 15 de junio",
    title: "Piernas & Glúteos B",
    status: { label: "✓ Completada" },
    chips: [
      { label: "Intermedio", kind: "level" },
      { label: "⏱ 45 min", kind: "time" },
      { label: "Piernas", kind: "muscle" },
      { label: "Glúteos", kind: "muscle2" },
    ],
  },
  {
    day: "MARTES · 16 de junio",
    title: "Piernas & Glúteos B",
    status: { label: "🛏 Descanso", rest: true },
    chips: [
      { label: "Intermedio", kind: "level" },
      { label: "⏱ 45 min", kind: "time" },
      { label: "Piernas", kind: "muscle" },
      { label: "Glúteos", kind: "muscle2" },
    ],
  },
  {
    day: "MIÉRCOLES · 17 de junio",
    title: "Piernas",
    status: { label: "🛏 Descanso", rest: true },
    chips: [
      { label: "Intermedio", kind: "level" },
      { label: "⏱ 45 min", kind: "time" },
      { label: "Glúteos", kind: "muscle2" },
      { label: "Piernas", kind: "muscle" },
    ],
  },
];

const RoutineChip: React.FC<{
  label: string;
  kind: "level" | "time" | "muscle" | "muscle2";
}> = ({ label, kind }) => {
  if (kind === "level")
    return <Chip label={label} color={COLORS.warn} bg={COLORS.warnBg} />;
  if (kind === "time")
    return <Chip label={label} color={COLORS.textMuted} bg={COLORS.surfaceAlt} />;
  if (kind === "muscle")
    return <Chip label={label} color={COLORS.text} bg={`${COLORS.purple}55`} />;
  return <Chip label={label} color={COLORS.text} bg={`${COLORS.pink}55`} />;
};

const RoutineCard: React.FC<{ routine: Routine }> = ({ routine }) => (
  <div
    style={{
      backgroundColor: COLORS.surface,
      borderRadius: 24,
      padding: 30,
      display: "flex",
      flexDirection: "column",
      gap: 16,
    }}
  >
    <div
      style={{
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
      }}
    >
      <span style={{ color: COLORS.textMuted, fontSize: 24, fontWeight: 700 }}>
        {routine.day}
      </span>
      <Chip
        label={routine.status.label}
        color={routine.status.rest ? COLORS.textMuted : COLORS.success}
        bg={routine.status.rest ? COLORS.surfaceAlt : COLORS.successBg}
      />
    </div>
    <span style={{ color: COLORS.text, fontSize: 38, fontWeight: 800 }}>
      {routine.title}
    </span>
    <div style={{ display: "flex", gap: 12, flexWrap: "wrap" }}>
      {routine.chips.map((c, i) => (
        <RoutineChip key={i} label={c.label} kind={c.kind} />
      ))}
    </div>
  </div>
);

// Recreation of the EnerGym "Mi Semana" view.
export const WeekScreen: React.FC = () => {
  return (
    <AbsoluteFill style={{ fontFamily, backgroundColor: COLORS.background }}>
      <StatusBar />
      <div
        style={{
          flex: 1,
          padding: "20px 40px 140px",
          display: "flex",
          flexDirection: "column",
          gap: 28,
        }}
      >
        {/* Header */}
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "flex-start",
          }}
        >
          <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
            <span style={{ color: COLORS.text, fontSize: 44, fontWeight: 900 }}>
              Mi Semana
            </span>
            <span style={{ color: COLORS.textMuted, fontSize: 24 }}>
              15 Jun — 21 Jun 2026
            </span>
          </div>
          <span style={{ fontSize: 28 }}>🌙</span>
        </div>

        {/* Day selector */}
        <div style={{ display: "flex", gap: 14 }}>
          {WEEK_DAYS.map((d, i) => {
            const active = i === 5;
            return (
              <div
                key={d.n}
                style={{
                  flex: 1,
                  borderRadius: 18,
                  padding: "18px 0",
                  background: active ? GRADIENT : COLORS.surface,
                  display: "flex",
                  flexDirection: "column",
                  alignItems: "center",
                  gap: 4,
                }}
              >
                <span
                  style={{
                    color: active ? COLORS.text : COLORS.textMuted,
                    fontSize: 22,
                    fontWeight: 700,
                  }}
                >
                  {d.l}
                </span>
                <span
                  style={{
                    color: COLORS.text,
                    fontSize: 30,
                    fontWeight: 900,
                  }}
                >
                  {d.n}
                </span>
              </div>
            );
          })}
        </div>

        {/* Routine cards */}
        <div style={{ display: "flex", flexDirection: "column", gap: 20 }}>
          {ROUTINES.map((r) => (
            <RoutineCard key={r.day} routine={r} />
          ))}
        </div>
      </div>
      <BottomNav active="semana" />
    </AbsoluteFill>
  );
};
