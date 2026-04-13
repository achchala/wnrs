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
                Text("We’re Not\nReally Strangers")
                    .font(Theme.helveticaBold(size: 34))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.ink)
                Spacer()
                VStack(spacing: 12) {
                    Button(action: onNewGame) {
                        Text("New game")
                            .font(Theme.helveticaBold(size: 17))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.red)

                    Button(action: onHowToPlay) {
                        Text("How to play")
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
    @State private var count = 2
    @State private var names: [String] = ["", ""]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Group")
                    .font(Theme.helveticaBold(size: 13))
                Stepper(value: $count, in: 2...6) {
                    Text("\(count) players")
                        .font(Theme.helveticaBold(size: 17))
                }
                .onChange(of: count) { _, newValue in
                    if names.count < newValue {
                        names.append(contentsOf: Array(repeating: "", count: newValue - names.count))
                    } else if names.count > newValue {
                        names = Array(names.prefix(newValue))
                    }
                }

                Text("Names")
                    .font(Theme.helveticaBold(size: 13))
                    .padding(.top, 8)
                ForEach(0..<count, id: \.self) { i in
                    TextField("Player \(i + 1) name (optional)", text: $names[i])
                        .textFieldStyle(.roundedBorder)
                }

                Text("Turns rotate automatically: one person reads the card, the next person answers.")
                    .font(Theme.helvetica(size: 13))
                    .foregroundStyle(Theme.ink.opacity(0.55))
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .background(Theme.paper)
        .navigationTitle("Setup")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button { dismiss() } label: {
                    Text("Back").font(Theme.helveticaBold(size: 17))
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    session.configure(playerNames: Array(names.prefix(count)))
                    onStart()
                } label: {
                    Text("Start").font(Theme.helveticaBold(size: 17))
                }
            }
        }
    }
}

struct HowToPlayView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Play with 2–6 people. One person draws a card and reads it aloud; the next person answers. Take turns—after each card, the reader role moves clockwise.")
                Text("Work through three levels: Perception, Connection, and Reflection. The app tracks at least 15 answered questions per level (wildcards don’t count toward that minimum).")
                Text("Wildcards are actions—do what they say, then tap done when you’re finished.")
                Text("Each reader still has a single “Dig deeper” prompt for the whole game, like the clear card in the box.")
                Text("After the third level, you’ll get one final card to close the session.")
            }
            .font(Theme.helveticaBold(size: 16))
            .foregroundStyle(Theme.ink.opacity(0.85))
            .padding(20)
        }
        .background(Theme.paper)
        .navigationTitle("How to play")
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
        .navigationTitle("Game")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    onExitToHome()
                } label: {
                    Text("End").font(Theme.helveticaBold(size: 17))
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
                                Text("Dig deeper (reader, once per person)")
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

private struct TurnStrip: View {
    var session: GameSession

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(session.currentLevel.title.uppercased())
                .font(Theme.helveticaBold(size: 12))
                .tracking(1.6)
                .foregroundStyle(Theme.red.opacity(0.55))
            if session.playerCount > 1 {
                Text("\(session.playerNames[session.drawerIndex]) reads · \(session.playerNames[session.answererIndex]) answers")
                    .font(Theme.helveticaBold(size: 17))
                    .foregroundStyle(Theme.ink)
            } else {
                Text("Solo mode: read, then answer honestly.")
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
        let need = session.cardsRequiredPerLevel
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
            Text("You’ve answered at least \(session.cardsRequiredPerLevel) questions in \(session.currentLevel.title). Move on when the group feels ready.")
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
            Text("Take a breath. Nothing here was saved—just people talking.")
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
    }
}

#Preview {
    NavigationStack {
        HomeView(onNewGame: {}, onHowToPlay: {})
    }
}
