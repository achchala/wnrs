import type { Card, Level, Phase, QuestionPack } from "./types";
import { nextLevel } from "./types";

export type PlayMode = "duo" | "group";

/** Duo: 15 question cards per level; Dig Deeper resets each level. Group: 2×players per level; Dig once per person whole game. */
export function cardsRequiredForLevel(s: GameSession): number {
  if (s.playMode === "duo") return 15;
  const n = s.playerNames.length;
  return Math.max(6, 2 * n);
}

export function poolForLevel(pack: QuestionPack, level: Level): string[] {
  switch (level) {
    case "perception":
      return pack.perception;
    case "connection":
      return pack.connection;
    case "reflection":
      return pack.reflection;
  }
}

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
  playMode: PlayMode;
  playerNames: string[];
  currentLevel: Level;
  drawerIndex: number;
  answeredInLevel: number;
  currentCard: Card | null;
  showingPackIntro: boolean;
  showingLevelIntro: boolean;
  phase: Phase;
  digDeeperAvailable: boolean[];
  decks: Record<Level, string[]>;
  wildPile: string[];
}

export function createSession(pack: QuestionPack): GameSession {
  return {
    pack,
    playMode: "duo",
    playerNames: [],
    currentLevel: "perception",
    drawerIndex: 0,
    answeredInLevel: 0,
    currentCard: null,
    showingPackIntro: false,
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

export function configurePlayers(
  s: GameSession,
  rawNames: string[],
  startLevel: Level,
  playMode: PlayMode,
  firstReaderIndex: number,
): GameSession {
  const fallback = rawNames.map((_, i) => `Player ${i + 1}`);
  const playerNames = rawNames.map((n, i) => {
    const t = n.trim();
    return t.length ? t : fallback[i]!;
  });
  const n = playerNames.length;
  const drawer = n > 0 ? firstReaderIndex % n : 0;
  const hasPackIntro =
    startLevel === "perception" && (s.pack.introParagraphs?.length ?? 0) > 0;
  return resetDecks({
    ...s,
    playMode,
    playerNames,
    digDeeperAvailable: playerNames.map(() => true),
    drawerIndex: drawer,
    currentLevel: startLevel,
    answeredInLevel: 0,
    currentCard: null,
    showingPackIntro: hasPackIntro,
    showingLevelIntro: true,
    phase: "playing",
  });
}

/** Jump to another level: fresh shuffled deck; duo refreshes Dig Deeper for that jump. */
export function switchToLevel(s: GameSession, level: Level): GameSession {
  if (level === s.currentLevel && s.phase === "playing" && !s.currentCard) {
    return s;
  }
  const dig =
    s.playMode === "duo" ? s.playerNames.map(() => true) : [...s.digDeeperAvailable];
  return {
    ...s,
    currentLevel: level,
    answeredInLevel: 0,
    currentCard: null,
    showingPackIntro: false,
    showingLevelIntro: true,
    phase: "playing",
    digDeeperAvailable: dig,
    decks: { ...s.decks, [level]: shuffle(poolForLevel(s.pack, level)) },
  };
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
  const hasPackIntro = (s.pack.introParagraphs?.length ?? 0) > 0;
  return resetDecks({
    ...s,
    drawerIndex: 0,
    currentLevel: "perception",
    answeredInLevel: 0,
    currentCard: null,
    showingPackIntro: hasPackIntro,
    showingLevelIntro: true,
    phase: "playing",
    digDeeperAvailable: s.playerNames.map(() => true),
  });
}

export function dismissPackIntro(s: GameSession): GameSession {
  return { ...s, showingPackIntro: false };
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
  if (wasQ && answeredInLevel >= cardsRequiredForLevel(s) && s.phase === "playing") {
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
  return {
    ...s,
    decks: { ...s.decks, [key]: shuffle(poolForLevel(s.pack, key)) },
  };
}

export function continueToNextLevel(s: GameSession): GameSession {
  const n = nextLevel(s.currentLevel);
  if (n) {
    const dig =
      s.playMode === "duo" ? s.playerNames.map(() => true) : [...s.digDeeperAvailable];
    return {
      ...s,
      currentLevel: n,
      answeredInLevel: 0,
      showingLevelIntro: true,
      phase: "playing",
      currentCard: null,
      digDeeperAvailable: dig,
    };
  }
  const prompts = s.pack.finalPrompts;
  const text =
    prompts.length > 0
      ? pick(prompts)
      : "Write a private note to each other. Fold, exchange, and read later on your own.";
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
