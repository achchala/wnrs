import SwiftUI
import UIKit

struct RootView: View {
    @StateObject private var session = GameSession()
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
                    .font(.system(size: 34, weight: .heavy, design: .default))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.ink)
                Text("A quiet phone version—no accounts, no servers.")
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundStyle(Theme.ink.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                Spacer()
                VStack(spacing: 12) {
                    Button(action: onNewGame) {
                        Text("New game")
                            .font(.system(size: 17, weight: .semibold, design: .default))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.red)

                    Button(action: onHowToPlay) {
                        Text("How to play")
                            .font(.system(size: 17, weight: .semibold, design: .default))
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
    @ObservedObject var session: GameSession
    let onStart: () -> Void
    @State private var count = 2
    @State private var names: [String] = ["", ""]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section {
                Stepper(value: $count, in: 2...6) {
                    Text("\(count) players")
                }
                .onChange(of: count) { _, newValue in
                    if names.count < newValue {
                        names.append(contentsOf: Array(repeating: "", count: newValue - names.count))
                    } else if names.count > newValue {
                        names = Array(names.prefix(newValue))
                    }
                }
            } header: {
                Text("Group")
            }

            Section {
                ForEach(0..<count, id: \.self) { i in
                    TextField("Player \(i + 1) name (optional)", text: $names[i])
                }
            } header: {
                Text("Names")
            } footer: {
                Text("Turns rotate automatically: one person reads the card, the next person answers.")
            }
        }
        .navigationTitle("Setup")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Back") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Start") {
                    session.configure(playerNames: Array(names.prefix(count)))
                    onStart()
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
            .font(.system(size: 16, weight: .regular, design: .default))
            .foregroundStyle(Theme.ink.opacity(0.85))
            .padding(20)
        }
        .background(Theme.paper)
        .navigationTitle("How to play")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PlayView: View {
    @ObservedObject var session: GameSession
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
                Button("End") {
                    onExitToHome()
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
    @ObservedObject var session: GameSession

    var body: some View {
        VStack(spacing: 0) {
            if session.showingLevelIntro {
                VStack(spacing: 18) {
                    LevelIntroCardView(level: session.currentLevel)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                    Button("Begin level") {
                        session.dismissLevelIntro()
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
                    Button("Next turn") {
                        session.markAnsweredAndAdvance()
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
                            .font(.system(size: 14, weight: .medium, design: .default))
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
                                    .font(.system(size: 17, weight: .semibold, design: .default))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Theme.red)
                        } else {
                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                session.drawNextQuestionCard()
                            } label: {
                                Text("Pull a question")
                                    .font(.system(size: 17, weight: .semibold, design: .default))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Theme.red)
                        }

                        Button {
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            session.drawWildcard()
                        } label: {
                            Text("Pull a wildcard")
                                .font(.system(size: 17, weight: .semibold, design: .default))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.bordered)

                        if session.currentDrawerCanDigDeeper {
                            Button {
                                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                session.useDigDeeper(forPlayerIndex: session.drawerIndex)
                            } label: {
                                Text("Dig deeper (reader, once per person)")
                                    .font(.system(size: 15, weight: .semibold, design: .default))
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
    @ObservedObject var session: GameSession

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(session.currentLevel.title.uppercased())
                .font(.system(size: 12, weight: .heavy, design: .default))
                .tracking(1.6)
                .foregroundStyle(Theme.red.opacity(0.55))
            if session.playerCount > 1 {
                Text("\(session.playerNames[session.drawerIndex]) reads · \(session.playerNames[session.answererIndex]) answers")
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundStyle(Theme.ink)
            } else {
                Text("Solo mode: read, then answer honestly.")
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundStyle(Theme.ink)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 22)
        .padding(.top, 10)
    }
}

private struct ProgressStrip: View {
    @ObservedObject var session: GameSession

    var body: some View {
        let done = session.answeredInLevel
        let need = session.cardsRequiredPerLevel
        VStack(alignment: .leading, spacing: 8) {
            ProgressView(value: Double(min(done, need)), total: Double(need)) {
                Text("Progress toward next level (\(done)/\(need) answered)")
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundStyle(Theme.ink.opacity(0.45))
            }
            .tint(Theme.red)
        }
        .padding(.horizontal, 22)
    }
}

private struct LevelGateView: View {
    @ObservedObject var session: GameSession

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Level complete")
                .font(.system(size: 28, weight: .heavy, design: .default))
            Text("You’ve answered at least \(session.cardsRequiredPerLevel) questions in \(session.currentLevel.title). Move on when the group feels ready.")
                .font(.system(size: 16, weight: .regular, design: .default))
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.ink.opacity(0.6))
                .padding(.horizontal, 28)
            VStack(spacing: 12) {
                if session.currentLevel.next != nil {
                    Button {
                        session.continueToNextLevel()
                    } label: {
                        Text("Continue to \(session.currentLevel.next!.title)")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.red)
                } else {
                    Button {
                        session.continueToNextLevel()
                    } label: {
                        Text("Draw final card")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.red)
                }

                Button {
                    session.stayInLevel()
                } label: {
                    Text("Stay in this level")
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
    @ObservedObject var session: GameSession

    var body: some View {
        VStack(spacing: 16) {
            if let card = session.currentCard {
                cardFinale(card)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
            }
            Button("End session") {
                session.endSession()
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.red)
            Spacer()
        }
    }

    @ViewBuilder
    private func cardFinale(_ card: CardKind) -> some View {
        switch card {
        case let .finalThought(text):
            FinalCardView(text: text)
        default:
            EmptyView()
        }
    }
}

private struct SessionDoneView: View {
    @ObservedObject var session: GameSession
    let onHome: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("That’s a wrap")
                .font(.system(size: 28, weight: .heavy, design: .default))
            Text("Take a breath. Nothing here was saved—just people talking.")
                .font(.system(size: 16, weight: .regular, design: .default))
                .foregroundStyle(Theme.ink.opacity(0.55))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
            VStack(spacing: 12) {
                Button {
                    session.newGameSamePlayers()
                } label: {
                    Text("Same players, new deck")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.red)

                Button("Home", action: onHome)
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
