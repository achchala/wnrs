import SwiftUI

enum Theme {
    static let red = Color(red: 0.89, green: 0.11, blue: 0.15)
    static let ink = Color.black
    static let paper = Color.white
    /// Solid fills instead of blur materials (much cheaper on GPU).
    static let wildcardFill = Color(red: 0.96, green: 0.96, blue: 0.97)
    static let digDeeperFill = Color(red: 0.93, green: 0.93, blue: 0.95)
    static let cornerRadius: CGFloat = 28
    static let footerSize: CGFloat = 11

    private static let helveticaBoldFace = "Helvetica-Bold"
    private static let helveticaRomanFace = "Helvetica"

    /// Primary face for cards and UI—matches the bold Helvetica on the deck.
    static func helveticaBold(size: CGFloat) -> Font {
        .custom(helveticaBoldFace, size: size)
    }

    /// Roman Helvetica for longer body copy (same family, easier to read in paragraphs).
    static func helvetica(size: CGFloat) -> Font {
        .custom(helveticaRomanFace, size: size)
    }

    static func cardTitleFont() -> Font {
        helveticaBold(size: 22)
    }

    static func cardBodyFont() -> Font {
        helveticaBold(size: 19)
    }
}
