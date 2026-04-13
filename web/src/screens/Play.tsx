import type { GameSession } from "../game";
import * as G from "../game";
import type { Card } from "../types";
import { levelNumber, levelSubtitle, levelTitle, nextLevel } from "../types";

export function Play({
  session,
  update,
  onHome,
}: {
  session: GameSession;
  update: (fn: (s: GameSession) => GameSession) => void;
  onHome: () => void;
}) {
  return (
    <div class="stack">
      <div class="topbar">
        <button type="button" class="btn btn-ghost" onClick={onHome}>
          End
        </button>
      </div>
      {session.phase === "done" && (
        <Done
          onAgain={() => update(G.newGameSamePlayers)}
          onHome={onHome}
        />
      )}
      {session.phase === "levelComplete" && <LevelGate session={session} update={update} />}
      {session.phase === "finale" && <Finale session={session} update={update} />}
      {session.phase === "playing" && <Playing session={session} update={update} />}
    </div>
  );
}

function Done({
  onAgain,
  onHome,
}: {
  onAgain: () => void;
  onHome: () => void;
}) {
  return (
    <div class="stack-grow" style={{ textAlign: "center", gap: "1rem" }}>
      <h1 style={{ fontSize: "1.5rem" }}>That’s a wrap</h1>
      <p class="muted" style={{ fontWeight: 400, lineHeight: 1.45 }}>
        Take a breath. Nothing here was saved—just people talking.
      </p>
      <div class="row" style={{ marginTop: "1.5rem" }}>
        <button type="button" class="btn btn-primary" onClick={onAgain}>
          Same players, new deck
        </button>
        <button type="button" class="btn btn-secondary" onClick={onHome}>
          Home
        </button>
      </div>
    </div>
  );
}

function LevelGate({
  session,
  update,
}: {
  session: GameSession;
  update: (fn: (s: GameSession) => GameSession) => void;
}) {
  const n = nextLevel(session.currentLevel);
  return (
    <div class="stack-grow" style={{ textAlign: "center", gap: "1rem" }}>
      <h1 style={{ fontSize: "1.5rem" }}>Level complete</h1>
      <p class="muted" style={{ fontWeight: 400, lineHeight: 1.45 }}>
        You’ve answered at least {G.CARDS_PER_LEVEL} questions in {levelTitle(session.currentLevel)}. Move on when
        the group feels ready.
      </p>
      <div class="row" style={{ marginTop: "0.5rem" }}>
        <button type="button" class="btn btn-primary" onClick={() => update(G.continueToNextLevel)}>
          {n ? `Continue to ${levelTitle(n)}` : "Draw final card"}
        </button>
        <button type="button" class="btn btn-secondary" onClick={() => update(G.stayInLevel)}>
          Stay in this level
        </button>
      </div>
    </div>
  );
}

function Finale({
  session,
  update,
}: {
  session: GameSession;
  update: (fn: (s: GameSession) => GameSession) => void;
}) {
  const c = session.currentCard;
  return (
    <div class="stack-grow">
      {c?.kind === "finalThought" && <CardFace card={c} />}
      <button type="button" class="btn btn-primary" style={{ marginTop: "1rem" }} onClick={() => update(G.endSession)}>
        End session
      </button>
    </div>
  );
}

function Playing({
  session,
  update,
}: {
  session: GameSession;
  update: (fn: (s: GameSession) => GameSession) => void;
}) {
  if (session.showingLevelIntro) {
    return (
      <div class="stack-grow">
        <div class="card card-red">
          <div class="card-inner">
            <span class="card-kicker" style={{ color: "rgba(255,255,255,0.9)" }}>
              LEVEL {levelNumber(session.currentLevel)}
            </span>
            <span class="card-body" style={{ color: "var(--paper)" }}>
              ({levelTitle(session.currentLevel).toUpperCase()})
            </span>
            <span class="card-body-sentence" style={{ color: "rgba(255,255,255,0.92)", fontWeight: 700 }}>
              {levelSubtitle(session.currentLevel)}
            </span>
          </div>
          <div class="card-footer" style={{ color: "rgba(255,255,255,0.85)" }}>
            WE'RE NOT REALLY STRANGERS
          </div>
        </div>
        <button type="button" class="btn btn-primary" style={{ marginTop: "1rem" }} onClick={() => update(G.dismissLevelIntro)}>
          Begin level
        </button>
      </div>
    );
  }

  if (session.currentCard) {
    return (
      <div class="stack-grow">
        <CardFace card={session.currentCard} />
        <button type="button" class="btn btn-primary" style={{ marginTop: "1rem" }} onClick={() => update(G.markAnsweredAndAdvance)}>
          Next turn
        </button>
      </div>
    );
  }

  const left = G.questionsRemaining(session);
  const done = session.answeredInLevel;
  const need = G.CARDS_PER_LEVEL;
  const drawer = session.playerNames[session.drawerIndex] ?? "";
  const answerer = session.playerNames[G.answererIndex(session)] ?? "";

  return (
    <div class="stack-grow">
      <p class="card-kicker" style={{ color: "var(--red)", margin: 0 }}>
        {levelTitle(session.currentLevel).toUpperCase()}
      </p>
      {session.playerNames.length > 1 ? (
        <p style={{ margin: "0.25rem 0 0", fontSize: "1.05rem" }}>
          {drawer} reads · {answerer} answers
        </p>
      ) : (
        <p style={{ margin: "0.25rem 0 0", fontSize: "1.05rem" }}>Solo: read, then answer honestly.</p>
      )}
      <div class="progress-wrap" style={{ marginTop: "0.75rem" }}>
        <label>
          Progress ({done}/{need} answered)
        </label>
        <progress value={Math.min(done, need)} max={need} />
      </div>
      {left === 0 && (
        <p class="muted" style={{ textAlign: "center", fontSize: "0.85rem", lineHeight: 1.4 }}>
          You’ve gone through every card in this level. Reshuffle to keep playing, or finish the level from the menu
          after 15 answers.
        </p>
      )}
      <div class="row" style={{ marginTop: "auto", paddingTop: "1rem" }}>
        {left === 0 ? (
          <button type="button" class="btn btn-primary" onClick={() => update(G.reshuffleLevel)}>
            Reshuffle this level
          </button>
        ) : (
          <button type="button" class="btn btn-primary" onClick={() => update(G.drawQuestion)}>
            Pull a question
          </button>
        )}
        <button type="button" class="btn btn-secondary" onClick={() => update(G.drawWildcard)}>
          Pull a wildcard
        </button>
        {G.drawerCanDig(session) && (
          <button type="button" class="btn btn-ghost" onClick={() => update((s) => G.useDigDeeper(s, s.drawerIndex))}>
            Dig deeper (reader, once per person)
          </button>
        )}
      </div>
    </div>
  );
}

function CardFace({ card }: { card: Card }) {
  switch (card.kind) {
    case "question":
      return (
        <div class="card card-paper">
          <div class="card-inner">
            <span class="card-kicker" style={{ color: "var(--red)" }}>
              LEVEL {levelNumber(card.level)}
            </span>
            <p class="card-body">{card.text}</p>
          </div>
          <div class="card-footer" style={{ color: "var(--red)" }}>
            WE'RE NOT REALLY STRANGERS
          </div>
        </div>
      );
    case "wildcard":
      return (
        <div class="card card-frost">
          <div class="card-inner">
            <span class="card-kicker">WILDCARD</span>
            <p class="card-body">{card.text}</p>
          </div>
          <div class="card-footer" style={{ opacity: 0.45 }}>
            WE'RE NOT REALLY STRANGERS
          </div>
        </div>
      );
    case "digDeeper":
      return (
        <div class="card card-dig">
          <div class="card-inner">
            <span class="card-kicker" style={{ opacity: 0.9 }}>
              DIG DEEPER
            </span>
            <p class="card-body-sentence">{card.text}</p>
          </div>
          <div class="card-footer" style={{ opacity: 0.35 }}>
            WE'RE NOT REALLY STRANGERS
          </div>
        </div>
      );
    case "finalThought":
      return (
        <div class="card card-paper" style={{ color: "var(--ink)" }}>
          <div class="card-inner">
            <span class="card-kicker" style={{ color: "var(--ink)", opacity: 0.45 }}>
              FINAL CARD
            </span>
            <p class="card-body-sentence">{card.text}</p>
          </div>
          <div class="card-footer" style={{ color: "var(--ink)", opacity: 0.4 }}>
            WE'RE NOT REALLY STRANGERS
          </div>
        </div>
      );
  }
}
