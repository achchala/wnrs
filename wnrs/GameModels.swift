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
    /// Expansion-only screens shown before Level 1 (e.g. Honest Dating intro).
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
    struct Option: Identifiable {
        let id: String
        let title: String
        let pack: QuestionPack
    }

    /// All playable decks bundled with the app.
    static let options: [Option] = loadOptions()

    static var defaultPack: QuestionPack { options.first?.pack ?? fallbackPack }

    private static func loadOptions() -> [Option] {
        var out: [Option] = []
        if let p = loadJSON("questions") {
            out.append(Option(id: "core", title: "Original", pack: p))
        }
        if let p = loadJSON("honest-dating") {
            out.append(Option(id: "honest-dating", title: "Honest dating", pack: p))
        }
        if out.isEmpty { out.append(Option(id: "fallback", title: "Fallback", pack: fallbackPack)) }
        return out
    }

    private static func loadJSON(_ name: String) -> QuestionPack? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let pack = try? JSONDecoder().decode(QuestionPack.self, from: data) else { return nil }
        return pack
    }

    private static var fallbackPack: QuestionPack {
        QuestionPack(
            introParagraphs: nil,
            perception: ["Bundle error: add JSON packs to Copy Bundle Resources."],
            connection: ["Bundle error: add JSON packs to Copy Bundle Resources."],
            reflection: ["Bundle error: add JSON packs to Copy Bundle Resources."],
            wildcards: ["Fix Copy Bundle Resources for question JSON files."],
            digDeeper: ["Say more about that."],
            finalPrompts: ["What are you taking away from tonight?"]
        )
    }
}
