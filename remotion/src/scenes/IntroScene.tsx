import {
  AbsoluteFill,
  Easing,
  interpolate,
  useCurrentFrame,
} from "remotion";
import { Background } from "../components/Background";
import { BrandLogo } from "../components/BrandLogo";
import { COLORS, fontFamily } from "../theme";

export const IntroScene: React.FC<{
  tagline: string;
}> = ({ tagline }) => {
  const frame = useCurrentFrame();

  const logoScale = interpolate(frame, [0, 28], [0.7, 1], {
    easing: Easing.bezier(0.34, 1.56, 0.64, 1),
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const logoOpacity = interpolate(frame, [0, 20], [0, 1], {
    extrapolateRight: "clamp",
  });

  const taglineY = interpolate(frame, [24, 50], [30, 0], {
    easing: Easing.bezier(0.16, 1, 0.3, 1),
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const taglineOpacity = interpolate(frame, [24, 50], [0, 1], {
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
          gap: 44,
        }}
      >
        <div
          style={{ transform: `scale(${logoScale})`, opacity: logoOpacity }}
        >
          <BrandLogo size={260} />
        </div>
        <span
          style={{
            color: COLORS.textMuted,
            fontSize: 40,
            fontWeight: 600,
            textAlign: "center",
            transform: `translateY(${taglineY}px)`,
            opacity: taglineOpacity,
            maxWidth: 820,
          }}
        >
          {tagline}
        </span>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
