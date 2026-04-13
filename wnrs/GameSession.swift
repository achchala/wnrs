import Foundation
import Observation

@MainActor
@Observable
final class GameSession {
    private(set) var playerNames: [String] = []
    private(set) var currentLevel: GameLevel = .perception
    private(set) var drawerIndex: Int = 0
    private(set) var answeredInLevel: Int = 0
    private(set) var currentCard: CardKind?
    private(set) var showingLevelIntro = true
    private(set) var phase: Phase = .playing

    /// One dig-deeper per player for the session; index aligns with `playerNames`.
    private(set) var digDeeperAvailable: [Bool] = []

    private let pack: QuestionPack
    private var decks: [GameLevel: [String]] = [:]
    private var wildPile: [String] = []

    let cardsRequiredPerLevel = 15

    enum Phase {
        case playing
        case levelComplete
        case finale
        case done
    }

    init(pack: QuestionPack = PackLoader.pack) {
        self.pack = pack
    }

    var playerCount: Int { playerNames.count }

    var answererIndex: Int {
        guard playerCount > 1 else { return 0 }
        return (drawerIndex + 1) % playerCount
    }

    var currentDrawerCanDigDeeper: Bool {
        guard drawerIndex < digDeeperAvailable.count else { return false }
        return digDeeperAvailable[drawerIndex]
    }

    var questionsRemainingInLevel: Int {
        decks[currentLevel]?.count ?? 0
    }

    func configure(playerNames names: [String]) {
        let trimmed = names.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let fallback = (1...names.count).map { "Player \($0)" }
        playerNames = zip(trimmed, fallback).map { a, b in a.isEmpty ? b : a }
        digDeeperAvailable = Array(repeating: true, count: playerNames.count)
        resetDecks()
        drawerIndex = 0
        currentLevel = .perception
        answeredInLevel = 0
        currentCard = nil
        showingLevelIntro = true
        phase = .playing
    }

    func dismissLevelIntro() {
        showingLevelIntro = false
    }

    func drawNextQuestionCard() {
        guard var deck = decks[currentLevel], !deck.isEmpty else { return }
        let q = deck.removeLast()
        decks[currentLevel] = deck
        currentCard = .question(q, level: currentLevel)
    }

    func drawWildcard() {
        guard !wildPile.isEmpty else { return }
        let w = wildPile.removeLast()
        if wildPile.isEmpty { wildPile = pack.wildcards.shuffled() }
        currentCard = .wildcard(w)
    }

    func useDigDeeper(forPlayerIndex index: Int) {
        guard index < digDeeperAvailable.count, digDeeperAvailable[index] else { return }
        digDeeperAvailable[index] = false
        let prompt = pack.digDeeper.randomElement() ?? "Go one layer deeper—what’s the real answer?"
        currentCard = .digDeeper(prompt)
    }

    func markAnsweredAndAdvance() {
        let wasLevelQuestion: Bool
        if case .question = currentCard {
            wasLevelQuestion = true
        } else {
            wasLevelQuestion = false
        }
        currentCard = nil
        if wasLevelQuestion {
            answeredInLevel += 1
        }
        guard playerCount > 0 else { return }
        drawerIndex = (drawerIndex + 1) % playerCount

        if wasLevelQuestion, answeredInLevel >= cardsRequiredPerLevel, phase == .playing {
            phase = .levelComplete
        }
    }

    func reshuffleCurrentLevelDeck() {
        switch currentLevel {
        case .perception: decks[.perception] = pack.perception.shuffled()
        case .connection: decks[.connection] = pack.connection.shuffled()
        case .reflection: decks[.reflection] = pack.reflection.shuffled()
        }
    }

    func continueToNextLevel() {
        if let next = currentLevel.next {
            currentLevel = next
            answeredInLevel = 0
            showingLevelIntro = true
            phase = .playing
            currentCard = nil
        } else {
            startFinale()
        }
    }

    func stayInLevel() {
        phase = .playing
    }

    func startFinale() {
        phase = .finale
        let line = pack.finalPrompts.randomElement() ?? "Before you go—what are you taking away from this?"
        currentCard = .finalThought(line)
    }

    func endSession() {
        phase = .done
        currentCard = nil
    }

    func newGameSamePlayers() {
        resetDecks()
        drawerIndex = 0
        currentLevel = .perception
        answeredInLevel = 0
        currentCard = nil
        showingLevelIntro = true
        phase = .playing
        digDeeperAvailable = Array(repeating: true, count: playerNames.count)
    }

    private func resetDecks() {
        decks[.perception] = pack.perception.shuffled()
        decks[.connection] = pack.connection.shuffled()
        decks[.reflection] = pack.reflection.shuffled()
        wildPile = pack.wildcards.shuffled()
    }
}
