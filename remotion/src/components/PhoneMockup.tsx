import { COLORS } from "../theme";

// A simple phone frame that wraps any screen content. The dynamic island and
// rounded bezel give the showcase a real-device feel without external assets.
export const PhoneMockup: React.FC<{
  children: React.ReactNode;
  width?: number;
}> = ({ children, width = 540 }) => {
  const height = width * (19.5 / 9);
  const bezel = width * 0.03;
  const radius = width * 0.16;

  return (
    <div
      style={{
        width,
        height,
        borderRadius: radius,
        backgroundColor: "#000000",
        padding: bezel,
        boxShadow: "0 40px 120px rgba(0,0,0,0.6)",
        position: "relative",
      }}
    >
      <div
        style={{
          width: "100%",
          height: "100%",
          borderRadius: radius - bezel,
          overflow: "hidden",
          backgroundColor: COLORS.backgroundAlt,
          position: "relative",
        }}
      >
        {children}
      </div>
      {/* Dynamic island */}
      <div
        style={{
          position: "absolute",
          top: bezel + width * 0.03,
          left: "50%",
          transform: "translateX(-50%)",
          width: width * 0.3,
          height: width * 0.08,
          borderRadius: width * 0.04,
          backgroundColor: "#000000",
        }}
      />
    </div>
  );
};
