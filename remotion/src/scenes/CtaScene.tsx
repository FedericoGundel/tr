import {
  AbsoluteFill,
  Easing,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { Background } from "../components/Background";
import { COLORS, GRADIENT, fontFamily } from "../theme";

export const CtaScene: React.FC<{
  brand: string;
  cta: string;
  url: string;
}> = ({ brand, cta, url }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const titleOpacity = interpolate(frame, [0, 20], [0, 1], {
    extrapolateRight: "clamp",
  });
  const titleY = interpolate(frame, [0, 25], [40, 0], {
    easing: Easing.bezier(0.16, 1, 0.3, 1),
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const buttonScale = spring({
    frame: frame - 22,
    fps,
    config: { damping: 12, stiffness: 120 },
  });

  // Subtle pulse on the CTA button after it appears.
  const pulse = 1 + 0.03 * Math.sin((frame - 40) / 6);
  const buttonScaleFinal = frame > 40 ? buttonScale * pulse : buttonScale;

  const urlOpacity = interpolate(frame, [45, 65], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill>
      <Background />
      <AbsoluteFill
        style={{
          fontFamily,
          alignItems: "center",
          justifyContent: "center",
          gap: 50,
          padding: 70,
        }}
      >
        <span
          style={{
            color: COLORS.text,
            fontSize: 82,
            fontWeight: 900,
            textAlign: "center",
            lineHeight: 1.05,
            opacity: titleOpacity,
            transform: `translateY(${titleY}px)`,
          }}
        >
          Tu mejor versión
          <br />
          <span style={{ color: COLORS.pink }}>empieza hoy</span>
        </span>

        <div
          style={{
            transform: `scale(${buttonScaleFinal})`,
            background: GRADIENT,
            color: COLORS.text,
            fontSize: 46,
            fontWeight: 900,
            padding: "30px 70px",
            borderRadius: 999,
            boxShadow: `0 20px 60px ${COLORS.pink}55`,
          }}
        >
          {cta}
        </div>

        <div
          style={{
            opacity: urlOpacity,
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            gap: 14,
            position: "absolute",
            bottom: 110,
          }}
        >
          <span style={{ color: COLORS.text, fontSize: 44, fontWeight: 800 }}>
            {brand}
          </span>
          <span style={{ color: COLORS.pink, fontSize: 32, fontWeight: 600 }}>
            {url}
          </span>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
