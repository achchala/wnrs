import SwiftUI
import UIKit

@main
struct WNRSApp: App {
    init() {
        let title = UIFont(name: "Helvetica-Bold", size: 17) ?? .boldSystemFont(ofSize: 17)
        let large = UIFont(name: "Helvetica-Bold", size: 34) ?? .boldSystemFont(ofSize: 34)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.titleTextAttributes = [.font: title]
        appearance.largeTitleTextAttributes = [.font: large]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: title], for: .normal)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
