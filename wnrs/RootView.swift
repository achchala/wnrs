import SwiftUI
import UIKit

private enum Haptics {
    private static let light = UIImpactFeedbackGenerator(style: .light)
    private static let soft = UIImpactFeedbackGenerator(style: .soft)
    private static let rigid = UIImpactFeedbackGenerator(style: .rigid)

    static func prepare() {
        light.prepare()
        soft.prepare()
        rigid.prepare()
    }

    static func lightImpact() { light.impactOccurred() }
    static func softImpact() { soft.impactOccurred() }
    static func rigidImpact() { rigid.impactOccurred() }
}

struct RootView: View {
    @State private var session = GameSession()
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(
                onNewGame: { path.append(Route.setup) },
                onHowToPlay: { path.append(Route.howTo) }
            )
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .setup:
                    SetupView(session: session) {
                        path.append(Route.play)
                    }
                case .play:
                    PlayView(session: session) {
                        path = NavigationPath()
                    }
                case .howTo:
                    HowToPlayView()
                }
            }
        }
        .tint(Theme.red)
    }
}

private enum Route: Hashable {
    case setup
    case play
    case howTo
}

struct HomeView: View {
    let onNewGame: () -> Void
    let onHowToPlay: () -> Void

    var body: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()
            VStack(spacing: 20) {
                Spacer()
                Text("WE'RE NOT\nREALLY STRANGERS")
                    .font(Theme.helveticaBold(size: 34))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.ink)
                Spacer()
                VStack(spacing: 12) {
                    Button(action: onNewGame) {
                        Text("NEW GAME")
                            .font(Theme.helveticaBold(size: 17))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.red)

                    Button(action: onHowToPlay) {
                        Text("HOW TO PLAY")
                            .font(Theme.helveticaBold(size: 17))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SetupView: View {
    var session: GameSession
    let onStart: () -> Void
    @State private var mode: GameSession.PlayMode = .duo
    @State private var groupCount = 3
    @State private var names: [String] = ["", ""]
    @State private var firstReaderIndex = 0
    @Environment(\.dismiss) private var dismiss

    private var activeCount: Int {
        mode == .duo ? 2 : groupCount
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("How you’re playing")
                    .font(Theme.helveticaBold(size: 13))
                Picker("Mode", selection: $mode) {
                    Text("Two players").tag(GameSession.PlayMode.duo)
                    Text("Group (3–6)").tag(GameSession.PlayMode.group)
                }
                .pickerStyle(.segmented)
                .onChange(of: mode) { _, new in
                    syncNames(for: new)
                }

                if mode == .group {
                    Stepper(value: $groupCount, in: 3...6) {
                        Text("\(groupCount) players")
                            .font(Theme.helveticaBold(size: 17))
                    }
                    .onChange(of: groupCount) { _, _ in
                        syncNames(for: mode)
                    }
                }

                Text("Names")
                    .font(Theme.helveticaBold(size: 13))
                    .padding(.top, 8)
                ForEach(0..<activeCount, id: \.self) { i in
                    TextField("Player \(i + 1) name (optional)", text: $names[i])
                        .textFieldStyle(.roundedBorder)
                }

                if mode == .duo {
                    Text("Who reads the first card? (Tip: wikiHow suggests a staring contest—first to blink is Player 1.)")
                        .font(Theme.helvetica(size: 13))
                        .foregroundStyle(Theme.ink.opacity(0.55))
                        .padding(.top, 4)
                    Picker("First reader", selection: $firstReaderIndex) {
                        Text(labelForPlayer(0)).tag(0)
                        Text(labelForPlayer(1)).tag(1)
                    }
                    .pickerStyle(.segmented)
                }

                Text(footerHint)
                    .font(Theme.helvetica(size: 13))
                    .foregroundStyle(Theme.ink.opacity(0.55))
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .textCase(.uppercase)
        }
        .background(Theme.paper)
        .navigationTitle("SETUP")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button { dismiss() } label: {
                    Text("Back").font(Theme.helveticaBold(size: 17)).textCase(.uppercase)
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    session.configure(
                        playerNames: Array(names.prefix(activeCount)),
                        mode: mode,
                        firstReaderIndex: mode == .duo ? firstReaderIndex : 0
                    )
                    onStart()
                } label: {
                    Text("Start").font(Theme.helveticaBold(size: 17)).textCase(.uppercase)
                }
            }
        }
    }

    private var footerHint: String {
        switch mode {
        case .duo:
            return "Duo: alternate—one reads a Level 1 question, the other answers (then swap). After 15 Level 1 answers, move to Level 2, then Level 3. Dig Deeper resets each level."
        case .group:
            return "Group: reader reads aloud; everyone answers in your own way. When each person has been reader at least twice, move up a level (app tracks \(2 * activeCount) question cards per level). Dig Deeper: once per person for the whole game."
        }
    }

    private func labelForPlayer(_ i: Int) -> String {
        let n = names[i].trimmingCharacters(in: .whitespacesAndNewlines)
        return n.isEmpty ? "Player \(i + 1)" : n
    }

    private func syncNames(for mode: GameSession.PlayMode) {
        let target = mode == .duo ? 2 : groupCount
        if names.count < target {
            names.append(contentsOf: Array(repeating: "", count: target - names.count))
        } else if names.count > target {
            names = Array(names.prefix(target))
        }
        firstReaderIndex = min(firstReaderIndex, 1)
    }
}

struct HowToPlayView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("This app follows the usual WNRS flow (like the boxed game): Level 1 Perception → Level 2 Connection → Level 3 Reflection, then a final closing prompt. Wildcards are actions—do them, then tap next turn.")
                Text("Two players: alternate who reads and who answers. Use Dig Deeper when someone’s answer feels shallow—each of you gets a fresh Dig Deeper when you start a new level. Move up after 15 question cards at that level.")
                Text("Group (3–6): one reader, everyone answers however you like (out loud or popcorn). Move up after each person has read at least twice—here that means \(2)×(number of players) question cards per level. Dig Deeper: once per person for the whole game, like one tile in the middle.")
                Text("End: use the final card as a cue—often you’ll write private notes, fold them, exchange, and read later.")
            }
            .font(Theme.helveticaBold(size: 16))
            .foregroundStyle(Theme.ink.opacity(0.85))
            .padding(20)
            .textCase(.uppercase)
        }
        .background(Theme.paper)
        .navigationTitle("HOW TO PLAY")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PlayView: View {
    var session: GameSession
    let onExitToHome: () -> Void

    var body: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()
            content
        }
        .navigationTitle("GAME")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    onExitToHome()
                } label: {
                    Text("End").font(Theme.helveticaBold(size: 17)).textCase(.uppercase)
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch session.phase {
        case .done:
            SessionDoneView(session: session, onHome: onExitToHome)
        case .levelComplete:
            LevelGateView(session: session)
        case .finale:
            FinaleView(session: session)
        case .playing:
            PlayingBoardView(session: session)
        }
    }
}

private struct PlayingBoardView: View {
    var session: GameSession

    var body: some View {
        VStack(spacing: 0) {
            if session.showingLevelIntro {
                VStack(spacing: 18) {
                    LevelIntroCardView(level: session.currentLevel)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                    Button {
                        session.dismissLevelIntro()
                    } label: {
                        Text("Begin level").font(Theme.helveticaBold(size: 17))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.red)
                    Spacer()
                }
            } else if let card = session.currentCard {
                VStack(spacing: 16) {
                    cardView(for: card)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    Button {
                        session.markAnsweredAndAdvance()
                    } label: {
                        Text("Next turn").font(Theme.helveticaBold(size: 17))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.red)
                    Spacer()
                }
            } else {
                VStack(spacing: 18) {
                    TurnStrip(session: session)
                    ProgressStrip(session: session)
                    if session.questionsRemainingInLevel == 0 {
                        Text("You’ve gone through every card in this level. Reshuffle to keep playing here, or finish the level when you’re ready.")
                            .font(Theme.helveticaBold(size: 14))
                            .foregroundStyle(Theme.ink.opacity(0.5))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 22)
                    }
                    Spacer()
                    VStack(spacing: 12) {
                        if session.questionsRemainingInLevel == 0 {
                            Button {
                                session.reshuffleCurrentLevelDeck()
                            } label: {
                                Text("Reshuffle this level")
                                    .font(Theme.helveticaBold(size: 17))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Theme.red)
                        } else {
                            Button {
                                Haptics.lightImpact()
                                session.drawNextQuestionCard()
                            } label: {
                                Text("Pull a question")
                                    .font(Theme.helveticaBold(size: 17))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Theme.red)
                        }

                        Button {
                            Haptics.softImpact()
                            session.drawWildcard()
                        } label: {
                            Text("Pull a wildcard")
                                .font(Theme.helveticaBold(size: 17))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.bordered)

                        if session.currentDrawerCanDigDeeper {
                            Button {
                                Haptics.rigidImpact()
                                session.useDigDeeper(forPlayerIndex: session.drawerIndex)
                            } label: {
                                Text(session.playMode == .duo
                                    ? "Dig deeper (reader — resets next level)"
                                    : "Dig deeper (reader — once each, whole game)")
                                    .font(Theme.helveticaBold(size: 15))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            .buttonStyle(.borderless)
                            .foregroundStyle(Theme.ink.opacity(0.55))
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 24)
                }
            }
        }
        .textCase(.uppercase)
        .onAppear { Haptics.prepare() }
    }

    @ViewBuilder
    private func cardView(for card: CardKind) -> some View {
        switch card {
        case let .question(text, level):
            QuestionCardView(text: text, level: level)
        case let .wildcard(text):
            WildcardCardView(text: text)
        case let .digDeeper(text):
            DigDeeperCardView(text: text)
        case let .finalThought(text):
            FinalCardView(text: text)
        }
    }
}

private func levelCompleteBlurb(_ session: GameSession) -> String {
    let need = session.cardsRequiredForCurrentLevel
    let title = session.currentLevel.title
    if session.playMode == .duo {
        return "You’ve answered at least \(need) question cards in \(title). Move on when you’re ready—Dig Deeper refreshes for both of you in the next level."
    }
    return "You’ve reached \(need) question cards in \(title) (each person has been reader about twice). Move on when the group is ready."
}

private struct TurnStrip: View {
    var session: GameSession

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(session.currentLevel.title.uppercased())
                .font(Theme.helveticaBold(size: 12))
                .tracking(1.6)
                .foregroundStyle(Theme.red.opacity(0.55))
            if session.playMode == .duo, session.playerCount == 2 {
                Text("\(session.playerNames[session.drawerIndex]) reads · \(session.playerNames[session.answererIndex]) answers — then swap.")
                    .font(Theme.helveticaBold(size: 17))
                    .foregroundStyle(Theme.ink)
            } else if session.playerCount > 1 {
                Text("\(session.playerNames[session.drawerIndex]) reads aloud · everyone answers; tap next when your group is ready.")
                    .font(Theme.helveticaBold(size: 17))
                    .foregroundStyle(Theme.ink)
            } else {
                Text("Add players in setup.")
                    .font(Theme.helveticaBold(size: 17))
                    .foregroundStyle(Theme.ink)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 22)
        .padding(.top, 10)
    }
}

private struct ProgressStrip: View {
    var session: GameSession

    var body: some View {
        let done = session.answeredInLevel
        let need = session.cardsRequiredForCurrentLevel
        VStack(alignment: .leading, spacing: 8) {
            Text("Progress toward next level (\(done)/\(need) answered)")
                .font(Theme.helveticaBold(size: 13))
                .foregroundStyle(Theme.ink.opacity(0.45))
            ProgressView(value: Double(min(done, need)), total: Double(need))
                .tint(Theme.red)
        }
        .padding(.horizontal, 22)
    }
}

private struct LevelGateView: View {
    var session: GameSession

    private var nextLevel: GameLevel? { session.currentLevel.next }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Level complete")
                .font(Theme.helveticaBold(size: 28))
            Text(levelCompleteBlurb(session))
                .font(Theme.helvetica(size: 16))
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.ink.opacity(0.6))
                .padding(.horizontal, 28)
            VStack(spacing: 12) {
                Button {
                    session.continueToNextLevel()
                } label: {
                    Text(nextLevel.map { "Continue to \($0.title)" } ?? "Draw final card")
                        .font(Theme.helveticaBold(size: 17))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.red)

                Button {
                    session.stayInLevel()
                } label: {
                    Text("Stay in this level")
                        .font(Theme.helveticaBold(size: 17))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 24)
            Spacer()
        }
        .textCase(.uppercase)
    }
}

private struct FinaleView: View {
    var session: GameSession

    var body: some View {
        VStack(spacing: 16) {
            if case let .finalThought(text) = session.currentCard {
                FinalCardView(text: text)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
            }
            Button {
                session.endSession()
            } label: {
                Text("End session").font(Theme.helveticaBold(size: 17))
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.red)
            Spacer()
        }
        .textCase(.uppercase)
    }
}

private struct SessionDoneView: View {
    var session: GameSession
    let onHome: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("That’s a wrap")
                .font(Theme.helveticaBold(size: 28))
            Text("Take a breath. Nothing was saved in the app—if you exchanged notes, save those yourself.")
                .font(Theme.helvetica(size: 16))
                .foregroundStyle(Theme.ink.opacity(0.55))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
            VStack(spacing: 12) {
                Button {
                    session.newGameSamePlayers()
                } label: {
                    Text("Same players, new deck")
                        .font(Theme.helveticaBold(size: 17))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.red)

                Button(action: onHome) {
                    Text("Home").font(Theme.helveticaBold(size: 17))
                }
                    .buttonStyle(.bordered)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
        .textCase(.uppercase)
    }
}

#Preview {
    NavigationStack {
        HomeView(onNewGame: {}, onHowToPlay: {})
    }
}
