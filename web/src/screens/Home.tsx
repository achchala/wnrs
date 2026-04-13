import { useState } from "preact/hooks";
import type { QuestionPack } from "../types";

type CatalogKind = "original" | "dating" | null;

function CatalogSection({ title, items }: { title: string; items: string[] }) {
  return (
    <section class="catalog-section">
      <h3 class="catalog-section-title">{title}</h3>
      <ol class="catalog-list">
        {items.map((text, i) => (
          <li key={i}>{text}</li>
        ))}
      </ol>
    </section>
  );
}

function QuestionCatalogModal({
  title,
  pack,
  onClose,
}: {
  title: string;
  pack: QuestionPack;
  onClose: () => void;
}) {
  return (
    <div
      class="modal-backdrop"
      role="dialog"
      aria-modal="true"
      aria-labelledby="catalog-modal-title"
      onClick={onClose}
    >
      <div class="modal-panel catalog-modal" onClick={(e) => e.stopPropagation()}>
        <div class="modal-header">
          <h2 id="catalog-modal-title">{title}</h2>
          <button type="button" class="btn btn-ghost modal-close" onClick={onClose}>
            Close
          </button>
        </div>
        <div class="modal-body">
          <CatalogSection title="Level 1 — Perception" items={pack.perception} />
          <CatalogSection title="Level 2 — Connection" items={pack.connection} />
          <CatalogSection title="Level 3 — Reflection" items={pack.reflection} />
          <CatalogSection title="Wildcards" items={pack.wildcards} />
        </div>
      </div>
    </div>
  );
}

export function Home({
  onNewGame,
  corePack,
  datingExpansionPack,
}: {
  onNewGame: () => void;
  corePack: QuestionPack;
  datingExpansionPack: QuestionPack | null;
}) {
  const [how, setHow] = useState(false);
  const [catalog, setCatalog] = useState<CatalogKind>(null);

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
          <p>level 1 perception, level 2 connection, level 3 reflection, then a closing prompt.</p>
          <p>
            two players: alternate who reads and who answers. fifteen question cards per level. each person's dig
            deeper refreshes when you start a new level.
          </p>
          <p>
            group (3–6): one reader, everyone answers. when each person has read about twice, move up (so that's
            2×(number of players) question cards per level). dig deeper once per person for the whole game.
          </p>
          <p>wildcards are actions; do them, then tap next turn.</p>
          {datingExpansionPack && (
            <p>
              optional: in setup, turn on “include honest dating expansion” to shuffle those cards into the deck with
              the originals.
            </p>
          )}
          <div class="howto-catalog-btns">
            <button type="button" class="btn btn-primary" onClick={() => setCatalog("original")}>
              All questions — original deck
            </button>
            <button
              type="button"
              class="btn btn-secondary"
              disabled={!datingExpansionPack}
              onClick={() => datingExpansionPack && setCatalog("dating")}
            >
              All questions — Honest dating expansion
            </button>
          </div>
        </div>
        {catalog === "original" && (
          <QuestionCatalogModal title="Original deck" pack={corePack} onClose={() => setCatalog(null)} />
        )}
        {catalog === "dating" && datingExpansionPack && (
          <QuestionCatalogModal
            title="Honest dating expansion"
            pack={datingExpansionPack}
            onClose={() => setCatalog(null)}
          />
        )}
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
