import SwiftUI
import MapKit

struct MapSearchView: View {
    @StateObject var viewModel: MapSearchViewModel
    @EnvironmentObject private var environment: ApplicationEnvironment

    init(viewModel: MapSearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Map(initialPosition: .region(viewModel.region), interactionModes: [.all], scope: .global) {
            ForEach(viewModel.walkers) { annotation in
                Annotation(annotation.walker.bio, coordinate: annotation.coordinate) {
                    VStack {
                        Text(annotation.walker.bio)
                            .font(.caption)
                            .padding(8)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        Image(systemName: "pawprint.fill")
                            .foregroundStyle(Color.accentColor)
                    }
                    .onTapGesture {
                        if case let .authenticated(user) = environment.sessionState {
                            environment.services.coordinator.openBooking(for: annotation.walker, owner: user)
                        }
                    }
                }
            }
        }
        .task { await viewModel.load() }
        .navigationTitle("map_tab_title".localized)
    }
}

#Preview {
    MapSearchView(viewModel: ApplicationEnvironment.preview.makeMapSearchViewModel())
        .environmentObject(ApplicationEnvironment.preview)
}
