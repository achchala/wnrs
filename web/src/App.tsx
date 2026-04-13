import type { QuestionPack } from "./types";
import { useGame } from "./useGame";
import { Home } from "./screens/Home";
import { Setup } from "./screens/Setup";
import { Play } from "./screens/Play";
import * as G from "./game";

export function App({
  corePack,
  datingExpansionPack,
}: {
  corePack: QuestionPack;
  datingExpansionPack: QuestionPack | null;
}) {
  const g = useGame(corePack);

  if (g.route === "home") {
    return (
      <Home
        onNewGame={g.goSetup}
        corePack={corePack}
        datingExpansionPack={datingExpansionPack}
      />
    );
  }
  if (g.route === "setup") {
    return (
      <Setup
        datingExpansionPack={datingExpansionPack}
        onBack={g.goHome}
        onStart={(includeHonestDating, names, startLevel, mode, firstReader) => {
          const playPack = G.mergePlayPack(corePack, datingExpansionPack, includeHonestDating);
          g.startGame(playPack, names, startLevel, mode, firstReader);
        }}
      />
    );
  }
  return <Play session={g.session} update={g.update} onHome={g.goHome} />;
}
