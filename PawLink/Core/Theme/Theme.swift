import SwiftUI

enum AppTheme {
    static let cornerRadius: CGFloat = 20
    static let shadowRadius: CGFloat = 12

    static var cardBackground: Color {
        Color(.systemBackground)
    }

    static var accent: Color {
        Color(.systemTeal)
    }
}

extension ShapeStyle where Self == Color {
    static var primaryText: Color { Color(.label) }
    static var secondaryText: Color { Color(.secondaryLabel) }
}

struct PillFilterStyle: ViewModifier {
    let isSelected: Bool

    func body(content: Content) -> some View {
        content
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(isSelected ? AppTheme.accent.opacity(0.2) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(isSelected ? AppTheme.accent : Color.clear, lineWidth: 1)
            )
    }
}

extension View {
    func pillStyle(isSelected: Bool) -> some View {
        modifier(PillFilterStyle(isSelected: isSelected))
    }
}
