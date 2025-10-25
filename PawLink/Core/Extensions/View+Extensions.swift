import SwiftUI

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: Color.black.opacity(0.05), radius: AppTheme.shadowRadius, x: 0, y: 4)
            )
    }

    func animatedAppearance() -> some View {
        self.transition(.opacity.combined(with: .scale))
            .animation(.easeInOut(duration: 0.25), value: UUID())
    }
}

struct SkeletonView: View {
    @State private var phase = 0.0

    var body: some View {
        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
            .fill(LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.1), .gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing))
            .mask(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(
                        LinearGradient(gradient: Gradient(stops: [
                            .init(color: .white.opacity(0), location: 0),
                            .init(color: .white.opacity(0.6), location: 0.5),
                            .init(color: .white.opacity(0), location: 1)
                        ]), startPoint: .leading, endPoint: .trailing)
                    )
                    .offset(x: CGFloat(phase) * 200 - 100)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}
