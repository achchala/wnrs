import type { Card, Level, Phase, QuestionPack } from "./types";
import { nextLevel } from "./types";

export const CARDS_PER_LEVEL = 15;

function shuffle<T>(arr: T[]): T[] {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j]!, a[i]!];
  }
  return a;
}

function pick<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)]!;
}

export interface GameSession {
  pack: QuestionPack;
  playerNames: string[];
  currentLevel: Level;
  drawerIndex: number;
  answeredInLevel: number;
  currentCard: Card | null;
  showingLevelIntro: boolean;
  phase: Phase;
  digDeeperAvailable: boolean[];
  decks: Record<Level, string[]>;
  wildPile: string[];
}

export function createSession(pack: QuestionPack): GameSession {
  return {
    pack,
    playerNames: [],
    currentLevel: "perception",
    drawerIndex: 0,
    answeredInLevel: 0,
    currentCard: null,
    showingLevelIntro: true,
    phase: "playing",
    digDeeperAvailable: [],
    decks: {
      perception: [],
      connection: [],
      reflection: [],
    },
    wildPile: [],
  };
}

export function configurePlayers(s: GameSession, rawNames: string[]): GameSession {
  const fallback = rawNames.map((_, i) => `Player ${i + 1}`);
  const playerNames = rawNames.map((n, i) => {
    const t = n.trim();
    return t.length ? t : fallback[i]!;
  });
  return resetDecks({
    ...s,
    playerNames,
    digDeeperAvailable: playerNames.map(() => true),
    drawerIndex: 0,
    currentLevel: "perception",
    answeredInLevel: 0,
    currentCard: null,
    showingLevelIntro: true,
    phase: "playing",
  });
}

function resetDecks(s: GameSession): GameSession {
  return {
    ...s,
    decks: {
      perception: shuffle(s.pack.perception),
      connection: shuffle(s.pack.connection),
      reflection: shuffle(s.pack.reflection),
    },
    wildPile: shuffle(s.pack.wildcards),
  };
}

export function newGameSamePlayers(s: GameSession): GameSession {
  return resetDecks({
    ...s,
    drawerIndex: 0,
    currentLevel: "perception",
    answeredInLevel: 0,
    currentCard: null,
    showingLevelIntro: true,
    phase: "playing",
    digDeeperAvailable: s.playerNames.map(() => true),
  });
}

export function dismissLevelIntro(s: GameSession): GameSession {
  return { ...s, showingLevelIntro: false };
}

export function drawQuestion(s: GameSession): GameSession {
  const deck = s.decks[s.currentLevel];
  if (!deck.length) return s;
  const next = [...deck];
  const text = next.pop()!;
  return {
    ...s,
    decks: { ...s.decks, [s.currentLevel]: next },
    currentCard: { kind: "question", text, level: s.currentLevel },
  };
}

export function drawWildcard(s: GameSession): GameSession {
  if (!s.wildPile.length) return s;
  let pile = [...s.wildPile];
  const text = pile.pop()!;
  if (!pile.length) pile = shuffle(s.pack.wildcards);
  return {
    ...s,
    wildPile: pile,
    currentCard: { kind: "wildcard", text },
  };
}

export function useDigDeeper(s: GameSession, index: number): GameSession {
  if (!s.digDeeperAvailable[index]) return s;
  const dig = [...s.digDeeperAvailable];
  dig[index] = false;
  const text = pick(s.pack.digDeeper);
  return {
    ...s,
    digDeeperAvailable: dig,
    currentCard: { kind: "digDeeper", text },
  };
}

export function markAnsweredAndAdvance(s: GameSession): GameSession {
  const wasQ = s.currentCard?.kind === "question";
  let answeredInLevel = s.answeredInLevel;
  if (wasQ) answeredInLevel += 1;
  const n = s.playerNames.length;
  const drawerIndex = n > 0 ? (s.drawerIndex + 1) % n : 0;
  let phase = s.phase;
  if (wasQ && answeredInLevel >= CARDS_PER_LEVEL && s.phase === "playing") {
    phase = "levelComplete";
  }
  return {
    ...s,
    currentCard: null,
    answeredInLevel,
    drawerIndex,
    phase,
  };
}

export function reshuffleLevel(s: GameSession): GameSession {
  const key = s.currentLevel;
  const pool =
    key === "perception"
      ? s.pack.perception
      : key === "connection"
        ? s.pack.connection
        : s.pack.reflection;
  return {
    ...s,
    decks: { ...s.decks, [key]: shuffle(pool) },
  };
}

export function continueToNextLevel(s: GameSession): GameSession {
  const n = nextLevel(s.currentLevel);
  if (n) {
    return {
      ...s,
      currentLevel: n,
      answeredInLevel: 0,
      showingLevelIntro: true,
      phase: "playing",
      currentCard: null,
    };
  }
  const text = pick(s.pack.finalPrompts);
  return {
    ...s,
    phase: "finale",
    currentCard: { kind: "finalThought", text },
  };
}

export function stayInLevel(s: GameSession): GameSession {
  return { ...s, phase: "playing" };
}

export function endSession(s: GameSession): GameSession {
  return { ...s, phase: "done", currentCard: null };
}

export function answererIndex(s: GameSession): number {
  const n = s.playerNames.length;
  if (n <= 1) return 0;
  return (s.drawerIndex + 1) % n;
}

export function drawerCanDig(s: GameSession): boolean {
  return Boolean(s.digDeeperAvailable[s.drawerIndex]);
}

export function questionsRemaining(s: GameSession): number {
  return s.decks[s.currentLevel].length;
}
