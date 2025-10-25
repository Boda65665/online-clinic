import SwiftUI

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }

    func pillStyle(selected: Bool) -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(selected ? Color.accentColor.opacity(0.2) : Color(.secondarySystemBackground))
            .clipShape(Capsule())
    }
}
