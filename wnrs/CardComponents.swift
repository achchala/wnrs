import SwiftUI

/// Generic chrome avoids `AnyView` type erasure (cheaper type-checking and diffing).
struct CardChrome<Content: View>: View {
    let background: Color
    let foreground: Color
    let footerForeground: Color
    @ViewBuilder private let content: () -> Content

    init(
        background: Color,
        foreground: Color,
        footerForeground: Color? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.background = background
        self.foreground = foreground
        self.footerForeground = footerForeground ?? foreground.opacity(0.85)
        self.content = content
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
                .font(Theme.helveticaBold(size: Theme.footerSize))
                .tracking(1.1)
                .textCase(.uppercase)
                .foregroundStyle(footerForeground)
                .padding(.bottom, 18)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 420)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .shadow(color: Color.black.opacity(0.1), radius: 12, y: 6)
    }
}

struct QuestionCardView: View {
    let text: String
    let level: GameLevel

    var body: some View {
        CardChrome(background: Theme.paper, foreground: Theme.red) {
            VStack(spacing: 14) {
                Text("LEVEL \(level.levelNumber)")
                    .font(Theme.helveticaBold(size: 13))
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
                    .font(Theme.helveticaBold(size: 16))
                    .tracking(1.2)
                Text(level.subtitle)
                    .font(Theme.helveticaBold(size: 15))
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
                .fill(Theme.wildcardFill)
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                Text("WILDCARD")
                    .font(Theme.helveticaBold(size: 13))
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
                    .font(Theme.helveticaBold(size: Theme.footerSize))
                    .tracking(1.1)
                    .textCase(.uppercase)
                    .foregroundStyle(Theme.ink.opacity(0.35))
                    .padding(.bottom, 18)
            }
        }
        .frame(minHeight: 420)
        .shadow(color: Color.black.opacity(0.08), radius: 10, y: 5)
    }
}

struct DigDeeperCardView: View {
    let text: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .fill(Theme.digDeeperFill)
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                Text("DIG DEEPER")
                    .font(Theme.helveticaBold(size: 15))
                    .tracking(2.4)
                    .foregroundStyle(Theme.ink)
                    .padding(.bottom, 12)
                Text(text)
                    .font(Theme.helveticaBold(size: 18))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                Spacer(minLength: 0)
                Text("WE'RE NOT REALLY STRANGERS")
                    .font(Theme.helveticaBold(size: Theme.footerSize))
                    .tracking(1.1)
                    .textCase(.uppercase)
                    .foregroundStyle(Theme.ink.opacity(0.3))
                    .padding(.bottom, 18)
            }
        }
        .frame(minHeight: 420)
        .shadow(color: Color.black.opacity(0.06), radius: 8, y: 4)
    }
}

struct FinalCardView: View {
    let text: String

    var body: some View {
        CardChrome(background: Theme.paper, foreground: Theme.ink, footerForeground: Theme.ink.opacity(0.4)) {
            VStack(spacing: 12) {
                Text("FINAL CARD")
                    .font(Theme.helveticaBold(size: 13))
                    .tracking(2)
                    .foregroundStyle(Theme.ink.opacity(0.45))
                Text(text)
                    .font(Theme.helveticaBold(size: 20))
                    .textCase(.none)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
