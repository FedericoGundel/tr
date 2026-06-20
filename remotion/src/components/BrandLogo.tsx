import { COLORS, GRADIENT, fontFamily } from "../theme";

// Approximation of the EnerGym logo: a gradient ring with a flexed-arm glyph
// and the "ENERGYM" gradient wordmark. Drop the real logo PNG into public/
// and swap this for an <Img> once available for exact brand fidelity.
export const BrandLogo: React.FC<{
  size?: number;
  showWordmark?: boolean;
}> = ({ size = 120, showWordmark = true }) => {
  const ring = size;
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: size * 0.18,
        fontFamily,
      }}
    >
      <div
        style={{
          width: ring,
          height: ring,
          borderRadius: "50%",
          background: GRADIENT,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          boxShadow: `0 0 ${size * 0.5}px ${COLORS.pink}55`,
        }}
      >
        <div
          style={{
            width: ring * 0.82,
            height: ring * 0.82,
            borderRadius: "50%",
            backgroundColor: COLORS.background,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: ring * 0.45,
          }}
        >
          💪
        </div>
      </div>
      {showWordmark ? (
        <span
          style={{
            fontSize: size * 0.42,
            fontWeight: 900,
            letterSpacing: size * 0.04,
            background: GRADIENT,
            WebkitBackgroundClip: "text",
            backgroundClip: "text",
            color: "transparent",
          }}
        >
          ENERGYM
        </span>
      ) : null}
    </div>
  );
};
