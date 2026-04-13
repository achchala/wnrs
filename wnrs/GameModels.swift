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
    static func load() -> QuestionPack {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let pack = try? JSONDecoder().decode(QuestionPack.self, from: data)
        else {
            fatalError("Missing or invalid questions.json in bundle.")
        }
        return pack
    }
}
