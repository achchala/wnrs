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
    /// Parsed once for the lifetime of the process (no repeat JSON decode).
    static let pack: QuestionPack = loadOnce()

    private static func loadOnce() -> QuestionPack {
        if let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let pack = try? JSONDecoder().decode(QuestionPack.self, from: data) {
            return pack
        }
        #if DEBUG
        assertionFailure(
            "questions.json missing or invalid — ensure WNRS/Resources/questions.json is in “Copy Bundle Resources”."
        )
        #endif
        // Avoid fatalError on the main thread in shipped builds; lets the UI load with a visible fallback.
        return QuestionPack(
            perception: ["Bundle error: add questions.json to the app target."],
            connection: ["Bundle error: add questions.json to the app target."],
            reflection: ["Bundle error: add questions.json to the app target."],
            wildcards: ["Fix Copy Bundle Resources for questions.json."],
            digDeeper: ["Say more about that."],
            finalPrompts: ["What are you taking away from tonight?"]
        )
    }
}
