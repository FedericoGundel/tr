import { AbsoluteFill } from "remotion";
import {
  linearTiming,
  springTiming,
  TransitionSeries,
} from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { slide } from "@remotion/transitions/slide";
import { z } from "zod";
import { IntroScene } from "./scenes/IntroScene";
import { FeaturesScene } from "./scenes/FeaturesScene";
import { ShowcaseScene } from "./scenes/ShowcaseScene";
import { CtaScene } from "./scenes/CtaScene";
import { COLORS, FPS } from "./theme";

export const energymPromoSchema = z.object({
  brand: z.string(),
  tagline: z.string(),
  cta: z.string(),
  url: z.string(),
  features: z.array(
    z.object({
      icon: z.string(),
      title: z.string(),
      desc: z.string(),
    }),
  ),
});

export type EnergymPromoProps = z.infer<typeof energymPromoSchema>;

// Scene lengths (in frames) and the transition between each pair. Exported so
// Root.tsx can derive the exact composition duration without magic numbers.
const SCENE_DURATIONS = [90, 135, 165, 135] as const;
const TRANSITION_FRAMES = 16;

export const TOTAL_DURATION =
  SCENE_DURATIONS.reduce((a, b) => a + b, 0) -
  TRANSITION_FRAMES * (SCENE_DURATIONS.length - 1);

const transitionTiming = linearTiming({ durationInFrames: TRANSITION_FRAMES });

export const EnergymPromo: React.FC<EnergymPromoProps> = ({
  brand,
  tagline,
  cta,
  url,
  features,
}) => {
  return (
    <AbsoluteFill style={{ backgroundColor: COLORS.background }}>
      <TransitionSeries>
        <TransitionSeries.Sequence durationInFrames={SCENE_DURATIONS[0]}>
          <IntroScene tagline={tagline} />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition
          presentation={fade()}
          timing={transitionTiming}
        />

        <TransitionSeries.Sequence durationInFrames={SCENE_DURATIONS[1]}>
          <FeaturesScene features={features} />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition
          presentation={slide({ direction: "from-right" })}
          timing={springTiming({
            config: { damping: 200 },
            durationInFrames: TRANSITION_FRAMES,
          })}
        />

        <TransitionSeries.Sequence durationInFrames={SCENE_DURATIONS[2]}>
          <ShowcaseScene />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition
          presentation={fade()}
          timing={transitionTiming}
        />

        <TransitionSeries.Sequence durationInFrames={SCENE_DURATIONS[3]}>
          <CtaScene brand={brand} cta={cta} url={url} />
        </TransitionSeries.Sequence>
      </TransitionSeries>
    </AbsoluteFill>
  );
};

export const defaultEnergymProps: EnergymPromoProps = {
  brand: "EnerGym",
  tagline: "Entrená. Crecé. Superáte.",
  cta: "Empezá a entrenar",
  url: "energym.devstudioweb.com",
  features: [
    {
      icon: "🗓️",
      title: "Tu rutina, cada día",
      desc: "Piernas, glúteos y más, organizadas por jornada.",
    },
    {
      icon: "✅",
      title: "Seguí tu semana",
      desc: "Marcá completadas y mirá tus descansos.",
    },
    {
      icon: "🔥",
      title: "Logros y rachas",
      desc: "Racha, medallas y tiempo total entrenado.",
    },
  ],
};

// Re-export for convenience.
export { FPS };
