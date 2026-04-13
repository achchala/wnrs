import { useCallback, useMemo, useState } from "preact/hooks";
import type { Level, QuestionPack } from "./types";
import * as G from "./game";
import type { GameSession, PlayMode } from "./game";

export type Route = "home" | "setup" | "play";

export function useGame(pack: QuestionPack) {
  const [session, setSession] = useState<GameSession>(() => G.createSession(pack));
  const [route, setRoute] = useState<Route>("home");

  const goSetup = useCallback(() => setRoute("setup"), []);
  const goHome = useCallback(() => {
    setRoute("home");
    setSession(G.createSession(pack));
  }, [pack]);

  const startGame = useCallback(
    (
      names: string[],
      startLevel: Level,
      playMode: PlayMode,
      firstReaderIndex: number,
    ) => {
      setSession((s) => G.configurePlayers(s, names, startLevel, playMode, firstReaderIndex));
      setRoute("play");
    },
    [],
  );

  const update = useCallback((fn: (s: GameSession) => GameSession) => {
    setSession(fn);
  }, []);

  return useMemo(
    () => ({
      pack,
      session,
      route,
      goSetup,
      goHome,
      startGame,
      update,
    }),
    [pack, session, route, goSetup, goHome, startGame, update],
  );
}
