import type { QuestionPack } from "./types";
import { useGame } from "./useGame";
import { Home } from "./screens/Home";
import { Setup } from "./screens/Setup";
import { Play } from "./screens/Play";

export function App({ pack }: { pack: QuestionPack }) {
  const g = useGame(pack);

  if (g.route === "home") {
    return <Home onNewGame={g.goSetup} />;
  }
  if (g.route === "setup") {
    return <Setup onBack={g.goHome} onStart={g.startGame} />;
  }
  return <Play session={g.session} update={g.update} onHome={g.goHome} />;
}
