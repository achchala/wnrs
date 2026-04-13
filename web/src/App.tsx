import type { PackOption } from "./types";
import { useGame } from "./useGame";
import { Home } from "./screens/Home";
import { Setup } from "./screens/Setup";
import { Play } from "./screens/Play";

export function App({ packOptions }: { packOptions: PackOption[] }) {
  const initial = packOptions[0]?.pack;
  if (!initial) {
    return <p style={{ padding: "1rem" }}>No question packs loaded.</p>;
  }
  const g = useGame(initial);

  if (g.route === "home") {
    return <Home onNewGame={g.goSetup} />;
  }
  if (g.route === "setup") {
    return (
      <Setup
        packOptions={packOptions}
        onBack={g.goHome}
        onStart={(pack, names, startLevel, mode, firstReader) =>
          g.startGame(pack, names, startLevel, mode, firstReader)
        }
      />
    );
  }
  return <Play session={g.session} update={g.update} onHome={g.goHome} />;
}
