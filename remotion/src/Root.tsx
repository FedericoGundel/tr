import "./index.css";
import { Composition } from "remotion";
import {
  defaultEnergymProps,
  EnergymPromo,
  energymPromoSchema,
  FPS,
  TOTAL_DURATION,
} from "./EnergymPromo";

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="EnergymPromo"
        component={EnergymPromo}
        durationInFrames={TOTAL_DURATION}
        fps={FPS}
        width={1080}
        height={1920}
        schema={energymPromoSchema}
        defaultProps={defaultEnergymProps}
      />
      <Composition
        id="EnergymPromoSquare"
        component={EnergymPromo}
        durationInFrames={TOTAL_DURATION}
        fps={FPS}
        width={1080}
        height={1080}
        schema={energymPromoSchema}
        defaultProps={defaultEnergymProps}
      />
    </>
  );
};
