import { useState } from "preact/hooks";

export function Home({ onNewGame }: { onNewGame: () => void }) {
  const [how, setHow] = useState(false);

  if (how) {
    return (
      <div class="stack">
        <div class="topbar">
          <button type="button" class="btn btn-ghost" onClick={() => setHow(false)}>
            Back
          </button>
        </div>
        <div class="howto">
          <p>
            Matches the usual WNRS box flow: Level 1 Perception, Level 2 Connection, Level 3 Reflection, then a
            closing prompt (often private notes—like the Final Card).
          </p>
          <p>
            Two players: alternate who reads and who answers. Fifteen question cards per level. Dig Deeper
            refreshes when you start a new level.
          </p>
          <p>
            Group (3–6): one reader, everyone answers your way. When each person has read about twice, move up—here
            that’s 2×(number of players) question cards per level. Dig Deeper once per person for the whole game.
          </p>
          <p>Wildcards are actions—do them, then tap next turn.</p>
        </div>
      </div>
    );
  }

  return (
    <div class="stack">
      <div class="stack-grow">
        <h1>
          WE'RE NOT
          <br />
          REALLY STRANGERS
        </h1>
      </div>
      <div class="row">
        <button type="button" class="btn btn-primary" onClick={onNewGame}>
          NEW GAME
        </button>
        <button type="button" class="btn btn-secondary" onClick={() => setHow(true)}>
          HOW TO PLAY
        </button>
      </div>
    </div>
  );
}
