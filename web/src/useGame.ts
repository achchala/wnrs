import { useCallback, useMemo, useState } from "preact/hooks";
import type { QuestionPack } from "./types";
import * as G from "./game";
import type { GameSession } from "./game";

export type Route = "home" | "setup" | "play";

export function useGame(pack: QuestionPack) {
  const [session, setSession] = useState<GameSession>(() => G.createSession(pack));
  const [route, setRoute] = useState<Route>("home");

  const goSetup = useCallback(() => setRoute("setup"), []);
  const goHome = useCallback(() => {
    setRoute("home");
    setSession(G.createSession(pack));
  }, [pack]);

  const startGame = useCallback((names: string[]) => {
    setSession((s) => G.configurePlayers(s, names));
    setRoute("play");
  }, []);

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
