import { useState } from "preact/hooks";
import { LEVEL_ORDER, levelTitle, type Level } from "../types";
import type { PlayMode } from "../game";

export function Setup({
  onBack,
  onStart,
}: {
  onBack: () => void;
  onStart: (names: string[], startLevel: Level, mode: PlayMode, firstReaderIndex: number) => void;
}) {
  const [mode, setMode] = useState<PlayMode>("duo");
  const [groupCount, setGroupCount] = useState(3);
  const [names, setNames] = useState<string[]>(["", ""]);
  const [startLevel, setStartLevel] = useState<Level>("perception");
  const [firstReaderIndex, setFirstReaderIndex] = useState(0);

  const activeCount = mode === "duo" ? 2 : groupCount;

  const setName = (i: number, v: string) => {
    setNames((prev) => {
      const next = [...prev];
      next[i] = v;
      return next;
    });
  };

  const syncNames = (m: PlayMode, gc: number) => {
    const target = m === "duo" ? 2 : gc;
    setNames((prev) => {
      if (prev.length < target) return [...prev, ...Array(target - prev.length).fill("")];
      return prev.slice(0, target);
    });
    setFirstReaderIndex((i) => Math.min(i, 1));
  };

  const bumpGroupCount = (delta: number) => {
    setGroupCount((c) => {
      const n = Math.min(6, Math.max(3, c + delta));
      setNames((prev) => {
        if (prev.length < n) return [...prev, ...Array(n - prev.length).fill("")];
        return prev.slice(0, n);
      });
      return n;
    });
  };

  const labelFor = (i: number) => {
    const n = (names[i] ?? "").trim();
    return n.length ? n : `Player ${i + 1}`;
  };

  return (
    <div class="stack">
      <div class="topbar">
        <button type="button" class="btn btn-ghost" onClick={onBack}>
          Back
        </button>
      </div>
      <p class="muted" style={{ margin: 0 }}>
        How you’re playing
      </p>
      <div class="level-strip" role="group" aria-label="Play mode">
        <button
          type="button"
          class={`level-btn${mode === "duo" ? " level-btn-active" : ""}`}
          onClick={() => {
            setMode("duo");
            syncNames("duo", groupCount);
          }}
        >
          Two players
        </button>
        <button
          type="button"
          class={`level-btn${mode === "group" ? " level-btn-active" : ""}`}
          onClick={() => {
            setMode("group");
            syncNames("group", groupCount);
          }}
        >
          Group 3–6
        </button>
      </div>

      {mode === "group" && (
        <div class="stepper">
          <button type="button" onClick={() => bumpGroupCount(-1)} aria-label="Fewer players">
            −
          </button>
          <span>{groupCount} players</span>
          <button type="button" onClick={() => bumpGroupCount(1)} aria-label="More players">
            +
          </button>
        </div>
      )}

      <p class="muted" style={{ margin: "0.5rem 0 0" }}>
        Names
      </p>
      <div class="row">
        {Array.from({ length: activeCount }, (_, i) => (
          <label key={i}>
            Player {i + 1} (optional)
            <input
              type="text"
              autoComplete="off"
              autoCapitalize="words"
              value={names[i] ?? ""}
              onInput={(e) => setName(i, (e.currentTarget as HTMLInputElement).value)}
            />
          </label>
        ))}
      </div>

      {mode === "duo" && (
        <>
          <p class="muted" style={{ margin: "0.5rem 0 0", fontSize: "0.8rem", lineHeight: 1.4 }}>
            Who reads first?
          </p>
          <div class="level-strip" role="group" aria-label="First reader">
            <button
              type="button"
              class={`level-btn${firstReaderIndex === 0 ? " level-btn-active" : ""}`}
              onClick={() => setFirstReaderIndex(0)}
            >
              {labelFor(0)}
            </button>
            <button
              type="button"
              class={`level-btn${firstReaderIndex === 1 ? " level-btn-active" : ""}`}
              onClick={() => setFirstReaderIndex(1)}
            >
              {labelFor(1)}
            </button>
          </div>
        </>
      )}

      <p class="muted" style={{ margin: "0.5rem 0 0" }}>
        Starting level
      </p>
      <div class="level-strip" role="group" aria-label="Starting level">
        {LEVEL_ORDER.map((lvl) => (
          <button
            key={lvl}
            type="button"
            class={`level-btn${startLevel === lvl ? " level-btn-active" : ""}`}
            onClick={() => setStartLevel(lvl)}
          >
            {levelTitle(lvl)}
          </button>
        ))}
      </div>

      <p class="muted" style={{ margin: 0, fontWeight: 700, fontSize: "0.8rem", lineHeight: 1.4 }}>
        {mode === "duo"
          ? "Duo: alternate reader and answerer. 15 question cards per level. Dig Deeper resets each new level."
          : "Group: reader reads aloud; everyone answers. 2× players question cards per level. Dig Deeper once each for the whole game."}
      </p>
      <button
        type="button"
        class="btn btn-primary"
        style={{ marginTop: "auto" }}
        onClick={() => onStart(names.slice(0, activeCount), startLevel, mode, mode === "duo" ? firstReaderIndex : 0)}
      >
        Start
      </button>
    </div>
  );
}
