import SwiftUI

enum AppTheme {
    static let cornerRadius: CGFloat = 20
    static let shadowRadius: CGFloat = 12

    static func setupAppearance() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: UIFont.preferredFont(forTextStyle: .largeTitle)]
    }
}
