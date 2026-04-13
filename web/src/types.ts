export type Level = "perception" | "connection" | "reflection";

export type Phase = "playing" | "levelComplete" | "finale" | "done";

export interface QuestionPack {
  /** Expansion intro before Level 1 (optional). */
  introParagraphs?: string[];
  perception: string[];
  connection: string[];
  reflection: string[];
  wildcards: string[];
  digDeeper: string[];
  finalPrompts: string[];
}

export type Card =
  | { kind: "question"; text: string; level: Level }
  | { kind: "wildcard"; text: string }
  | { kind: "digDeeper"; text: string }
  | { kind: "finalThought"; text: string };

export const LEVEL_ORDER: Level[] = ["perception", "connection", "reflection"];

export function levelTitle(l: Level): string {
  return l.charAt(0).toUpperCase() + l.slice(1);
}

export function levelNumber(l: Level): number {
  return LEVEL_ORDER.indexOf(l) + 1;
}

export function nextLevel(l: Level): Level | null {
  const i = LEVEL_ORDER.indexOf(l);
  return i < LEVEL_ORDER.length - 1 ? LEVEL_ORDER[i + 1]! : null;
}

export function levelSubtitle(l: Level): string {
  switch (l) {
    case "perception":
      return "Icebreakers and first impressions.";
    case "connection":
      return "Love, emotions, and honesty.";
    case "reflection":
      return "The deepest level.";
  }
}
