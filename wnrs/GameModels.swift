import Foundation

enum GameLevel: String, Codable, CaseIterable, Identifiable {
    case perception
    case connection
    case reflection

    var id: String { rawValue }

    var title: String {
        switch self {
        case .perception: return "Perception"
        case .connection: return "Connection"
        case .reflection: return "Reflection"
        }
    }

    var levelNumber: Int {
        switch self {
        case .perception: return 1
        case .connection: return 2
        case .reflection: return 3
        }
    }

    var subtitle: String {
        switch self {
        case .perception: return "Icebreakers and first impressions."
        case .connection: return "Love, emotions, and honesty."
        case .reflection: return "The deepest level."
        }
    }

    var next: GameLevel? {
        switch self {
        case .perception: return .connection
        case .connection: return .reflection
        case .reflection: return nil
        }
    }
}

struct QuestionPack: Codable {
    /// Optional welcome screens before Level 1 (Honest dating expansion).
    var introParagraphs: [String]?
    var perception: [String]
    var connection: [String]
    var reflection: [String]
    var wildcards: [String]
    var digDeeper: [String]
    var finalPrompts: [String]
}

enum CardKind: Equatable {
    case question(String, level: GameLevel)
    case wildcard(String)
    case digDeeper(String)
    case finalThought(String)
}

enum PackLoader {
    /// Core WNRS deck only.
    static let corePack: QuestionPack = loadJSON("questions") ?? fallbackCore

    /// Honest dating expansion cards (optional file).
    static let datingExpansionPack: QuestionPack? = loadJSON("honest-dating")

    /// Deck used in play when the expansion toggle is on or off.
    static func playPack(includeHonestDatingExpansion: Bool) -> QuestionPack {
        guard includeHonestDatingExpansion, let d = datingExpansionPack else { return corePack }
        return QuestionPack(
            introParagraphs: d.introParagraphs,
            perception: corePack.perception + d.perception,
            connection: corePack.connection + d.connection,
            reflection: corePack.reflection + d.reflection,
            wildcards: corePack.wildcards + d.wildcards,
            digDeeper: corePack.digDeeper,
            finalPrompts: corePack.finalPrompts
        )
    }

    /// Backward-compatible default: core only.
    static var pack: QuestionPack { corePack }

    private static func loadJSON(_ name: String) -> QuestionPack? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let pack = try? JSONDecoder().decode(QuestionPack.self, from: data) else { return nil }
        return pack
    }

    private static var fallbackCore: QuestionPack {
        QuestionPack(
            introParagraphs: nil,
            perception: ["Bundle error: add questions.json to the app target."],
            connection: ["Bundle error: add questions.json to the app target."],
            reflection: ["Bundle error: add questions.json to the app target."],
            wildcards: ["Fix Copy Bundle Resources for questions.json."],
            digDeeper: ["Say more about that."],
            finalPrompts: ["What are you taking away from tonight?"]
        )
    }
}
