import SwiftUI

struct CardChrome: View {
    let background: Color
    let foreground: Color
    let footerForeground: Color
    let content: () -> AnyView

    init(
        background: Color,
        foreground: Color,
        footerForeground: Color? = nil,
        @ViewBuilder content: @escaping () -> some View
    ) {
        self.background = background
        self.foreground = foreground
        self.footerForeground = footerForeground ?? foreground.opacity(0.85)
        self.content = { AnyView(content()) }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            content()
                .foregroundStyle(foreground)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 22)
            Spacer(minLength: 0)
            Text("WE'RE NOT REALLY STRANGERS")
                .font(.system(size: Theme.footerSize, weight: .semibold, design: .default))
                .tracking(1.1)
                .textCase(.uppercase)
                .foregroundStyle(footerForeground)
                .padding(.bottom, 18)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 420)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 18, y: 10)
    }
}

struct QuestionCardView: View {
    let text: String
    let level: GameLevel

    var body: some View {
        CardChrome(background: Theme.paper, foreground: Theme.red) {
            VStack(spacing: 14) {
                Text("LEVEL \(level.levelNumber)")
                    .font(.system(size: 13, weight: .heavy, design: .default))
                    .tracking(1.4)
                    .textCase(.uppercase)
                    .foregroundStyle(Theme.red.opacity(0.55))
                Text(text)
                    .font(Theme.cardBodyFont())
                    .textCase(.uppercase)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct LevelIntroCardView: View {
    let level: GameLevel

    var body: some View {
        CardChrome(background: Theme.red, foreground: Theme.paper) {
            VStack(spacing: 12) {
                Text("LEVEL \(level.levelNumber)")
                    .font(Theme.cardTitleFont())
                    .tracking(2)
                    .textCase(.uppercase)
                Text("(\(level.title.uppercased()))")
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .tracking(1.2)
                Text(level.subtitle)
                    .font(.system(size: 15, weight: .medium, design: .default))
                    .textCase(.none)
                    .foregroundStyle(Theme.paper.opacity(0.92))
                    .padding(.top, 6)
            }
        }
    }
}

struct WildcardCardView: View {
    let text: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                Text("WILDCARD")
                    .font(.system(size: 13, weight: .heavy, design: .default))
                    .tracking(2)
                    .foregroundStyle(Theme.ink.opacity(0.45))
                    .padding(.bottom, 10)
                Text(text)
                    .font(Theme.cardBodyFont())
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 22)
                Spacer(minLength: 0)
                Text("WE'RE NOT REALLY STRANGERS")
                    .font(.system(size: Theme.footerSize, weight: .semibold, design: .default))
                    .tracking(1.1)
                    .textCase(.uppercase)
                    .foregroundStyle(Theme.ink.opacity(0.35))
                    .padding(.bottom, 18)
            }
        }
        .frame(minHeight: 420)
        .shadow(color: Color.black.opacity(0.1), radius: 16, y: 8)
    }
}

struct DigDeeperCardView: View {
    let text: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .fill(.thinMaterial)
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                Text("DIG DEEPER")
                    .font(.system(size: 15, weight: .heavy, design: .default))
                    .tracking(2.4)
                    .foregroundStyle(Theme.ink)
                    .padding(.bottom, 12)
                Text(text)
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                Spacer(minLength: 0)
                Text("WE'RE NOT REALLY STRANGERS")
                    .font(.system(size: Theme.footerSize, weight: .semibold, design: .default))
                    .tracking(1.1)
                    .textCase(.uppercase)
                    .foregroundStyle(Theme.ink.opacity(0.3))
                    .padding(.bottom, 18)
            }
        }
        .frame(minHeight: 420)
        .shadow(color: Color.black.opacity(0.08), radius: 14, y: 8)
    }
}

struct FinalCardView: View {
    let text: String

    var body: some View {
        CardChrome(background: Theme.paper, foreground: Theme.ink, footerForeground: Theme.ink.opacity(0.4)) {
            VStack(spacing: 12) {
                Text("FINAL CARD")
                    .font(.system(size: 13, weight: .heavy, design: .default))
                    .tracking(2)
                    .foregroundStyle(Theme.ink.opacity(0.45))
                Text(text)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .textCase(.none)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
