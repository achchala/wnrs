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
          <p>what's more romantic than being understood?</p>
          <p>
            level 1 perception, level 2 connection, level 3 reflection, then a closing prompt.
          </p>
          <p>
            two players: alternate who reads and who answers. fifteen question cards per level. each person's dig
            deeper refreshes when you start a new level.
          </p>
          <p>
            group (3–6): one reader, everyone answers. when each person has read about twice, move up (so that's
            2×(number of players) question cards per level). dig deeper once per person for the whole game.
          </p>
          <p>wildcards are actions; do them, then tap next turn.</p>
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
