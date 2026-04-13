import SwiftUI

enum Theme {
    static let red = Color(red: 0.89, green: 0.11, blue: 0.15)
    static let ink = Color.black
    static let paper = Color.white
    static let cornerRadius: CGFloat = 28
    static let footerSize: CGFloat = 11

    static func cardTitleFont() -> Font {
        .system(size: 22, weight: .heavy, design: .default)
    }

    static func cardBodyFont() -> Font {
        .system(size: 19, weight: .bold, design: .default)
    }
}
