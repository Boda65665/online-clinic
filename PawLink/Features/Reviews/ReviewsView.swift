import SwiftUI
import Combine
import SwiftData

final class ReviewsViewModel: ObservableObject {
    @Published var reviews: [Review] = []
    @Published var rating: Int = 5
    @Published var comment: String = ""
    @Published var error: AppError?

    private let walker: Walker
    private let currentUser: User
    private let context = ModelContext(AppModelContainer.shared.container)

    init(walker: Walker, currentUser: User) {
        self.walker = walker
        self.currentUser = currentUser
        fetch()
    }

    func fetch() {
        let descriptor = FetchDescriptor<Review>()
        reviews = (try? context.fetch(descriptor).filter { $0.walkerId == walker.id }) ?? []
    }

    func submit() {
        guard (1...5).contains(rating) else {
            error = .validation(NSLocalizedString("review.rating.invalid", comment: ""))
            return
        }
        let review = Review(bookingId: UUID(), ownerId: currentUser.id, walkerId: walker.id, rating: rating, comment: comment)
        context.insert(review)
        do {
            try context.save()
            comment = ""
            fetch()
        } catch {
            self.error = .unknown
        }
    }
}

struct ReviewsView: View {
    @StateObject var viewModel: ReviewsViewModel

    var body: some View {
        List {
            Section(NSLocalizedString("review.leave", comment: "")) {
                Picker(NSLocalizedString("review.rating", comment: ""), selection: $viewModel.rating) {
                    ForEach(1..<6) { rating in
                        Text(String(repeating: "⭐️", count: rating)).tag(rating)
                    }
                }
                TextField(NSLocalizedString("review.comment", comment: ""), text: $viewModel.comment)
                Button(NSLocalizedString("review.submit", comment: ""), action: viewModel.submit)
                    .buttonStyle(.borderedProminent)
            }

            Section(NSLocalizedString("review.list", comment: "")) {
                ForEach(viewModel.reviews, id: \.id) { review in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(String(repeating: "⭐️", count: review.rating))
                        Text(review.comment)
                            .font(.body)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle(Text(NSLocalizedString("review.title", comment: "")))
        .alert(viewModel.error?.localizedDescription ?? "", isPresented: Binding(get: { viewModel.error != nil }, set: { if !$0 { viewModel.error = nil } })) {
            Button("OK", role: .cancel) { viewModel.error = nil }
        }
    }
}
