import { COLORS, GRADIENT, fontFamily } from "../../theme";

// Minimal phone status bar (time + indicators) to make screens feel real.
export const StatusBar: React.FC = () => {
  return (
    <div
      style={{
        height: 56,
        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",
        padding: "0 36px",
        fontFamily,
        color: COLORS.text,
        fontSize: 26,
        fontWeight: 700,
      }}
    >
      <span>9:41</span>
      <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
        <span style={{ fontSize: 20 }}>📶</span>
        <span style={{ fontSize: 20 }}>🔋</span>
      </div>
    </div>
  );
};

const HomeIcon: React.FC<{ color: string }> = ({ color }) => (
  <svg width={34} height={34} viewBox="0 0 24 24" fill="none">
    <path
      d="M3 11l9-8 9 8M5 10v10h5v-6h4v6h5V10"
      stroke={color}
      strokeWidth={2}
      strokeLinecap="round"
      strokeLinejoin="round"
    />
  </svg>
);

const CalendarIcon: React.FC<{ color: string }> = ({ color }) => (
  <svg width={34} height={34} viewBox="0 0 24 24" fill="none">
    <rect
      x={3}
      y={4}
      width={18}
      height={17}
      rx={3}
      stroke={color}
      strokeWidth={2}
    />
    <path
      d="M3 9h18M8 2v4M16 2v4"
      stroke={color}
      strokeWidth={2}
      strokeLinecap="round"
    />
  </svg>
);

const ChartIcon: React.FC<{ color: string }> = ({ color }) => (
  <svg width={34} height={34} viewBox="0 0 24 24" fill="none">
    <path
      d="M3 17l5-5 4 4 8-9"
      stroke={color}
      strokeWidth={2}
      strokeLinecap="round"
      strokeLinejoin="round"
    />
  </svg>
);

type Tab = "hoy" | "semana" | "historial";

const NavItem: React.FC<{
  label: string;
  active: boolean;
  icon: (c: string) => React.ReactNode;
}> = ({ label, active, icon }) => {
  const color = active ? COLORS.pink : COLORS.textMuted;
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: 8,
      }}
    >
      {icon(color)}
      <span style={{ color, fontSize: 20, fontWeight: 700 }}>{label}</span>
    </div>
  );
};

export const BottomNav: React.FC<{ active: Tab }> = ({ active }) => {
  return (
    <div
      style={{
        position: "absolute",
        bottom: 0,
        left: 0,
        right: 0,
        height: 120,
        backgroundColor: COLORS.nav,
        borderTop: `1px solid ${COLORS.surfaceAlt}`,
        display: "flex",
        alignItems: "center",
        justifyContent: "space-around",
        padding: "0 30px 20px",
        fontFamily,
      }}
    >
      <NavItem
        label="Hoy"
        active={active === "hoy"}
        icon={(c) => <HomeIcon color={c} />}
      />
      <NavItem
        label="Mi Semana"
        active={active === "semana"}
        icon={(c) => <CalendarIcon color={c} />}
      />
      <NavItem
        label="Historial"
        active={active === "historial"}
        icon={(c) => <ChartIcon color={c} />}
      />
    </div>
  );
};

export const Chip: React.FC<{
  label: string;
  color: string;
  bg: string;
}> = ({ label, color, bg }) => (
  <span
    style={{
      backgroundColor: bg,
      color,
      fontSize: 22,
      fontWeight: 700,
      padding: "8px 18px",
      borderRadius: 999,
      fontFamily,
    }}
  >
    {label}
  </span>
);

export const GradientChip: React.FC<{ label: string }> = ({ label }) => (
  <span
    style={{
      background: GRADIENT,
      color: COLORS.text,
      fontSize: 22,
      fontWeight: 700,
      padding: "8px 18px",
      borderRadius: 999,
      fontFamily,
    }}
  >
    {label}
  </span>
);
