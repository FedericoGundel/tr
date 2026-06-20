import {
  AbsoluteFill,
  Easing,
  interpolate,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { Background } from "../components/Background";
import { PhoneMockup } from "../components/PhoneMockup";
import { LoginScreen } from "../components/screens/LoginScreen";
import { HomeScreen } from "../components/screens/HomeScreen";
import { WeekScreen } from "../components/screens/WeekScreen";
import { COLORS, fontFamily } from "../theme";

const SCREENS = [
  { Comp: LoginScreen, caption: "Ingresá en segundos" },
  { Comp: HomeScreen, caption: "Tu día, de un vistazo" },
  { Comp: WeekScreen, caption: "Planificá tu semana" },
] as const;

// Crossfade points between the three screens. The first screen is visible from
// the start, the last one holds until the end of the scene.
const CUTS = [53, 106] as const;
const FADE = 12;

// Opacity for screen `i` in a hold-then-crossfade carousel.
const screenOpacity = (frame: number, i: number) => {
  const fadeIn =
    i === 0
      ? 1
      : interpolate(frame, [CUTS[i - 1], CUTS[i - 1] + FADE], [0, 1], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
        });
  const fadeOut =
    i === SCREENS.length - 1
      ? 0
      : interpolate(frame, [CUTS[i], CUTS[i] + FADE], [0, 1], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
        });
  return fadeIn - fadeOut;
};

const PHONE_ASPECT = 19.5 / 9;
const CAPTION_HEIGHT = 80;
const TOP_PADDING = 70;
const GAP = 36;
const SIDE_MARGIN = 60;

export const ShowcaseScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { width, height } = useVideoConfig();

  // Fit the phone mockup within whatever space is left after the heading,
  // so the same scene works for vertical, square, or horizontal canvases.
  const availableHeight =
    height - TOP_PADDING - CAPTION_HEIGHT - GAP - SIDE_MARGIN;
  const availableWidth = width - SIDE_MARGIN * 2;
  const phoneWidth = Math.min(
    availableWidth,
    availableHeight / PHONE_ASPECT,
    560,
  );

  const phoneY = interpolate(frame, [0, 30], [120, 0], {
    easing: Easing.bezier(0.16, 1, 0.3, 1),
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const phoneOpacity = interpolate(frame, [0, 25], [0, 1], {
    extrapolateRight: "clamp",
  });
  const phoneRotate = interpolate(frame, [0, 60], [4, -1], {
    easing: Easing.bezier(0.45, 0, 0.55, 1),
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
          paddingTop: 70,
          gap: 36,
        }}
      >
        {/* Caption crossfades in sync with the screens */}
        <div style={{ height: 80, position: "relative", width: "100%" }}>
          {SCREENS.map(({ caption }, i) => {
            const op = screenOpacity(frame, i);
            return (
              <span
                key={caption}
                style={{
                  position: "absolute",
                  width: "100%",
                  textAlign: "center",
                  color: COLORS.text,
                  fontSize: 54,
                  fontWeight: 900,
                  opacity: op,
                }}
              >
                {caption}
              </span>
            );
          })}
        </div>

        <div
          style={{
            transform: `translateY(${phoneY}px) rotate(${phoneRotate}deg)`,
            opacity: phoneOpacity,
            position: "relative",
          }}
        >
          <PhoneMockup width={phoneWidth}>
            {SCREENS.map(({ Comp }, i) => {
              const op = screenOpacity(frame, i);
              return (
                <AbsoluteFill key={i} style={{ opacity: op }}>
                  <Comp />
                </AbsoluteFill>
              );
            })}
          </PhoneMockup>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
