import SwiftUI

struct HomeOwnerView: View {
    @StateObject var viewModel: HomeOwnerViewModel
    @EnvironmentObject private var environment: ApplicationEnvironment

    init(viewModel: HomeOwnerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(viewModel.walkers, id: \.id) { walker in
                        WalkerCard(walker: walker)
                            .onTapGesture {
                                if case let .authenticated(user) = environment.sessionState {
                                    viewModel.openBooking(for: walker, owner: user)
                                }
                            }
                    }
                }
                .padding()
            }
            .refreshable {
                await viewModel.load()
            }
            .task { await viewModel.load() }
            .navigationTitle("home_title".localized)
        }
    }
}

private struct WalkerCard: View {
    let walker: Walker

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(walker.ratePerHour as NSDecimalNumber) ₽/час")
                    .font(.headline)
                Spacer()
                Label("\(walker.ratingAvg, specifier: "%.1f")", systemImage: "star.fill")
                    .foregroundStyle(Color.yellow)
            }
            Text(walker.bio)
                .font(.body)
            HStack {
                ForEach(walker.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.footnote)
                        .pillStyle(selected: false)
                }
            }
        }
        .cardStyle()
    }
}

#Preview {
    HomeOwnerView(viewModel: ApplicationEnvironment.preview.makeHomeViewModel())
        .environmentObject(ApplicationEnvironment.preview)
}
