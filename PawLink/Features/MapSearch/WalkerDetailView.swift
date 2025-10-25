import SwiftUI

struct WalkerDetailView: View {
    let walker: Walker
    var onBook: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    Circle()
                        .fill(Color.accentColor.opacity(0.2))
                        .frame(width: 72, height: 72)
                        .overlay(Image(systemName: "pawprint"))
                    VStack(alignment: .leading, spacing: 8) {
                        Text(walker.bio)
                            .font(.title2)
                        HStack {
                            Label("\(walker.ratingAvg, specifier: "%.1f")", systemImage: "star.fill")
                            Text("\(walker.reviewsCount) отзывов")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Text("\(walker.ratePerHour as NSDecimalNumber) ₽ / час")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    Text("walker_tags".localized)
                        .font(.headline)
                    FlowLayout(tags: walker.tags)
                }

                Button("walker_book".localized, action: onBook)
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .navigationTitle("walker_detail_title".localized)
    }
}

private struct FlowLayout: View {
    let tags: [String]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 8)], spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.footnote)
                    .pillStyle(selected: false)
            }
        }
    }
}

#Preview {
    WalkerDetailView(walker: MockData.walkers().first!, onBook: {})
}
