import SwiftUI

struct ReviewsView: View {
    @StateObject var viewModel: ReviewsViewModel
    let walker: Walker
    let owner: User

    init(viewModel: ReviewsViewModel, walker: Walker, owner: User) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.walker = walker
        self.owner = owner
    }

    var body: some View {
        List(viewModel.reviews, id: \.id) { review in
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: index < review.rating ? "star.fill" : "star")
                            .foregroundStyle(Color.yellow)
                    }
                }
                Text(review.comment)
                    .font(.body)
                Text(review.createdAt, style: .date)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)
        }
        .onAppear {
            viewModel.load(for: walker, owner: owner)
        }
        .navigationTitle("reviews_title".localized)
    }
}

#Preview {
    ReviewsView(viewModel: ReviewsViewModel(), walker: MockData.walkers().first!, owner: MockData.previewOwner)
}
