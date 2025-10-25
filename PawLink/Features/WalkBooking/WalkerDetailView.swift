import SwiftUI
import Combine

final class WalkerDetailViewModel: ObservableObject {
    @Published var walker: Walker
    @Published var isFavorite = false

    let currentUser: User

    init(walker: Walker, currentUser: User) {
        self.walker = walker
        self.currentUser = currentUser
    }
}

struct WalkerDetailView: View {
    @StateObject var viewModel: WalkerDetailViewModel
    @State private var showReviews = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                AsyncImage(url: viewModel.walker.tags.contains("Фото") ? URL(string: "https://picsum.photos/400/300") : nil) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Rectangle().fill(Color(.systemGray5))
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                .shadow(radius: 8)

                VStack(alignment: .leading, spacing: 12) {
                    Text(viewModel.walker.userId.uuidString.prefix(6))
                        .font(.largeTitle)
                        .bold()
                    Text(viewModel.walker.bio)
                        .font(.body)
                    HStack {
                        Label("₽\(Int(viewModel.walker.ratePerHour))/ч", systemImage: "ruble")
                        Label("⭐️\(String(format: "%.1f", viewModel.walker.ratingAvg))", systemImage: "star.fill")
                    }
                    .font(.title3)
                    if viewModel.walker.isVerified {
                        Label(NSLocalizedString("walker.verified", comment: ""), systemImage: "checkmark.seal.fill")
                            .foregroundColor(.green)
                    }
                }

                Button(NSLocalizedString("walker.book", comment: "")) {
                    // TODO: connect to booking flow
                }
                .buttonStyle(.borderedProminent)

                Button(NSLocalizedString("walker.reviews", comment: "")) {
                    showReviews.toggle()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .navigationTitle(Text(NSLocalizedString("walker.detail", comment: "")))
        .sheet(isPresented: $showReviews) {
            ReviewsView(viewModel: ReviewsViewModel(walker: viewModel.walker, currentUser: viewModel.currentUser))
        }
    }
}
