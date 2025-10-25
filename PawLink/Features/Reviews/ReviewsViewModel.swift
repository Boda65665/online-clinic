import Foundation

@MainActor
final class ReviewsViewModel: ObservableObject {
    @Published var reviews: [Review] = []

    func load(for walker: Walker, owner: User) {
        reviews = MockData.reviews(owner: owner, walker: walker)
    }
}
