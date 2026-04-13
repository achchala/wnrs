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
            Play with 2–6 people. One person draws a card and reads it aloud; the next person answers.
            After each card, the reader moves clockwise.
          </p>
          <p>
            Work through Perception, Connection, and Reflection. The app tracks at least 15 answered
            questions per level (wildcards don’t count).
          </p>
          <p>Wildcards are actions—do them, then tap next turn.</p>
          <p>Each reader has one “Dig deeper” for the whole game.</p>
          <p>After the third level, you get one final card.</p>
        </div>
      </div>
    );
  }

  return (
    <div class="stack">
      <div class="stack-grow">
        <h1>
          We’re Not
          <br />
          Really Strangers
        </h1>
      </div>
      <div class="row">
        <button type="button" class="btn btn-primary" onClick={onNewGame}>
          New game
        </button>
        <button type="button" class="btn btn-secondary" onClick={() => setHow(true)}>
          How to play
        </button>
      </div>
    </div>
  );
}
