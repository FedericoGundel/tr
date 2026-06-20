import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import { COLORS } from "../theme";

// Animated dark backdrop with a slowly drifting accent glow. Pure transform /
// opacity driven by the frame, no CSS animations (forbidden in Remotion).
export const Background: React.FC = () => {
  const frame = useCurrentFrame();

  const glowY = interpolate(frame, [0, 200], [0, -120]);
  const glowOpacity = interpolate(
    frame,
    [0, 60, 140, 200],
    [0.35, 0.55, 0.45, 0.6],
  );

  return (
    <AbsoluteFill style={{ backgroundColor: COLORS.background }}>
      <div
        style={{
          position: "absolute",
          top: `${20 + 0}%`,
          left: "50%",
          width: 1200,
          height: 1200,
          transform: `translate(-50%, ${glowY}px)`,
          borderRadius: "50%",
          background: `radial-gradient(circle, ${COLORS.pink}40 0%, ${COLORS.purple}22 35%, transparent 65%)`,
          opacity: glowOpacity,
        }}
      />
      <AbsoluteFill
        style={{
          background:
            "linear-gradient(180deg, transparent 0%, rgba(0,0,0,0.4) 100%)",
        }}
      />
    </AbsoluteFill>
  );
};
