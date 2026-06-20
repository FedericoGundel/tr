import {
  AbsoluteFill,
  Easing,
  interpolate,
  Sequence,
  useCurrentFrame,
} from "remotion";
import { Background } from "../components/Background";
import { COLORS, fontFamily } from "../theme";

type Feature = { icon: string; title: string; desc: string };

const FeatureRow: React.FC<{ feature: Feature }> = ({ feature }) => {
  const frame = useCurrentFrame();
  const x = interpolate(frame, [0, 18], [80, 0], {
    easing: Easing.bezier(0.16, 1, 0.3, 1),
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const opacity = interpolate(frame, [0, 18], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <div
      style={{
        transform: `translateX(${x}px)`,
        opacity,
        display: "flex",
        alignItems: "center",
        gap: 28,
        backgroundColor: COLORS.surface,
        borderRadius: 28,
        padding: "32px 36px",
      }}
    >
      <div
        style={{
          width: 96,
          height: 96,
          borderRadius: 24,
          backgroundColor: COLORS.surfaceAlt,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontSize: 52,
          flexShrink: 0,
        }}
      >
        {feature.icon}
      </div>
      <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
        <span style={{ color: COLORS.text, fontSize: 42, fontWeight: 800 }}>
          {feature.title}
        </span>
        <span style={{ color: COLORS.textMuted, fontSize: 28, fontWeight: 500 }}>
          {feature.desc}
        </span>
      </div>
    </div>
  );
};

export const FeaturesScene: React.FC<{ features: Feature[] }> = ({
  features,
}) => {
  const frame = useCurrentFrame();
  const headingOpacity = interpolate(frame, [0, 18], [0, 1], {
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill>
      <Background />
      <AbsoluteFill
        style={{
          fontFamily,
          padding: "120px 70px",
          display: "flex",
          flexDirection: "column",
          gap: 36,
          justifyContent: "center",
        }}
      >
        <span
          style={{
            color: COLORS.text,
            fontSize: 64,
            fontWeight: 900,
            opacity: headingOpacity,
            lineHeight: 1.05,
          }}
        >
          Todo tu entrenamiento,
          <br />
          <span style={{ color: COLORS.pink }}>en una sola app</span>
        </span>
        <div style={{ display: "flex", flexDirection: "column", gap: 22 }}>
          {features.map((feature, i) => (
            <Sequence key={feature.title} from={12 + i * 12} layout="none">
              <FeatureRow feature={feature} />
            </Sequence>
          ))}
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
