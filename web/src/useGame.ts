import { useCallback, useMemo, useState } from "preact/hooks";
import type { Level, QuestionPack } from "./types";
import * as G from "./game";
import type { GameSession, PlayMode } from "./game";

export type Route = "home" | "setup" | "play";

export function useGame(defaultPack: QuestionPack) {
  const [session, setSession] = useState<GameSession>(() => G.createSession(defaultPack));
  const [route, setRoute] = useState<Route>("home");

  const goSetup = useCallback(() => setRoute("setup"), []);
  const goHome = useCallback(() => {
    setRoute("home");
    setSession((s) => G.createSession(s.pack));
  }, []);

  const startGame = useCallback(
    (
      pack: QuestionPack,
      names: string[],
      startLevel: Level,
      playMode: PlayMode,
      firstReaderIndex: number,
    ) => {
      setSession(
        G.configurePlayers(G.createSession(pack), names, startLevel, playMode, firstReaderIndex),
      );
      setRoute("play");
    },
    [],
  );

  const update = useCallback((fn: (s: GameSession) => GameSession) => {
    setSession(fn);
  }, []);

  return useMemo(
    () => ({
      session,
      route,
      goSetup,
      goHome,
      startGame,
      update,
    }),
    [session, route, goSetup, goHome, startGame, update],
  );
}
