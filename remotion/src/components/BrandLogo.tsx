import { Img, staticFile } from "remotion";
import { GRADIENT, fontFamily } from "../theme";

// Real EnerGym icon (cropped from the app's actual logo) paired with a CSS
// gradient wordmark, which stays crisp at any size unlike a rasterized one.
export const BrandLogo: React.FC<{
  size?: number;
  showWordmark?: boolean;
}> = ({ size = 120, showWordmark = true }) => {
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
      <Img
        src={staticFile("logo-icon.png")}
        style={{
          width: size,
          height: size,
          borderRadius: "50%",
          objectFit: "cover",
        }}
      />
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
