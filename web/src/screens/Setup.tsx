import { useState } from "preact/hooks";

export function Setup({
  onBack,
  onStart,
}: {
  onBack: () => void;
  onStart: (names: string[]) => void;
}) {
  const [count, setCount] = useState(2);
  const [names, setNames] = useState<string[]>(["", ""]);

  const setName = (i: number, v: string) => {
    setNames((prev) => {
      const next = [...prev];
      next[i] = v;
      return next;
    });
  };

  const bump = (delta: number) => {
    const n = Math.min(6, Math.max(2, count + delta));
    setCount(n);
    setNames((prev) => {
      if (n > prev.length) return [...prev, ...Array(n - prev.length).fill("")];
      return prev.slice(0, n);
    });
  };

  return (
    <div class="stack">
      <div class="topbar">
        <button type="button" class="btn btn-ghost" onClick={onBack}>
          Back
        </button>
      </div>
      <p class="muted" style={{ margin: 0 }}>
        Group
      </p>
      <div class="stepper">
        <button type="button" onClick={() => bump(-1)} aria-label="Fewer players">
          −
        </button>
        <span>
          {count} players
        </span>
        <button type="button" onClick={() => bump(1)} aria-label="More players">
          +
        </button>
      </div>
      <p class="muted" style={{ margin: "0.5rem 0 0" }}>
        Names
      </p>
      <div class="row">
        {Array.from({ length: count }, (_, i) => (
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
      <p class="muted" style={{ margin: 0, fontWeight: 700, fontSize: "0.8rem" }}>
        Turns rotate: one person reads the card, the next answers.
      </p>
      <button type="button" class="btn btn-primary" style={{ marginTop: "auto" }} onClick={() => onStart(names.slice(0, count))}>
        Start
      </button>
    </div>
  );
}
