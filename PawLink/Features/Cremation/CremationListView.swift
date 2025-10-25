import SwiftUI

struct CremationListView: View {
    @StateObject var viewModel: CremationListViewModel
    @EnvironmentObject private var environment: ApplicationEnvironment

    init(viewModel: CremationListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            filterPill(title: "all".localized, status: nil)
                            ForEach(CremationStatus.allCases, id: \.self) { status in
                                filterPill(title: status.rawValue.capitalized, status: status)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }

                ForEach(viewModel.orders, id: \.id) { order in
                    NavigationLink(destination: CremationDetailView(viewModel: CremationDetailViewModel(order: order, service: environment.services.cremation, pdfGenerator: CremationPDFGenerator(), notificationService: environment.services.notifications))) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(order.pickupAt, style: .date)
                                .font(.headline)
                            Text(order.pickupAddress)
                                .font(.body)
                            Text(order.status.rawValue.capitalized)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .task {
                if case let .authenticated(user) = environment.sessionState {
                    await viewModel.load(ownerId: user.id)
                }
            }
            .navigationTitle("cremation_title".localized)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        environment.services.coordinator.openCremationForm()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }

    private func filterPill(title: String, status: CremationStatus?) -> some View {
        Button(action: {
            withAnimation { viewModel.select(status: status) }
            Task {
                if case let .authenticated(user) = environment.sessionState {
                    await viewModel.load(ownerId: user.id)
                }
            }
        }) {
            Text(title)
                .pillStyle(selected: viewModel.selectedStatus == status)
        }
    }
}

#Preview {
    CremationListView(viewModel: ApplicationEnvironment.preview.makeCremationListViewModel())
        .environmentObject(ApplicationEnvironment.preview)
}
