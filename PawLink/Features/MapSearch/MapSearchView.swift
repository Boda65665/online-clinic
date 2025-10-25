import SwiftUI
import UIKit
import MapKit
import Combine

final class MapSearchViewModel: ObservableObject {
    @Published var walkers: [Walker] = []
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 55.751244, longitude: 37.618423), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    @Published var selectedWalker: Walker?
    @Published var filters: Set<Filter> = []
    @Published var isLoading = false
    @Published var error: AppError?

    enum Filter: String, CaseIterable, Identifiable {
        case verified
        case highRating
        case lowPrice

        var id: String { rawValue }
        var title: String {
            switch self {
            case .verified: return NSLocalizedString("filter.verified", comment: "")
            case .highRating: return NSLocalizedString("filter.rating", comment: "")
            case .lowPrice: return NSLocalizedString("filter.price", comment: "")
            }
        }
    }

    private let service: WalkerService
    private var cancellables = Set<AnyCancellable>()

    init(service: WalkerService = MockWalkerService()) {
        self.service = service
        fetch()
    }

    func fetch() {
        isLoading = true
        service.fetchWalkers()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] walkers in
                self?.walkers = walkers
            }
            .store(in: &cancellables)
    }

    var filteredWalkers: [Walker] {
        walkers.filter { walker in
            var include = true
            if filters.contains(.verified) { include = include && walker.isVerified }
            if filters.contains(.highRating) { include = include && walker.ratingAvg >= 4.5 }
            if filters.contains(.lowPrice) { include = include && walker.ratePerHour <= 1000 }
            return include
        }
    }
}

struct MapSearchView: View {
    @StateObject private var viewModel = MapSearchViewModel()
    @State private var showDetails = false
    let user: User

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.filteredWalkers) { walker in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: walker.serviceArea.centerLatitude, longitude: walker.serviceArea.centerLongitude)) {
                    Button {
                        viewModel.selectedWalker = walker
                    } label: {
                        VStack {
                            Image(systemName: "pawprint.circle.fill")
                                .font(.title)
                                .foregroundColor(.accentColor)
                            Text("₽\(Int(walker.ratePerHour))")
                                .font(.footnote)
                                .padding(6)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.top)

            filterChips
                .padding()

            if let walker = viewModel.selectedWalker {
                WalkerBottomSheet(walker: walker, onDismiss: { viewModel.selectedWalker = nil }, onDetails: { showDetails = true })
                    .transition(.move(edge: .bottom))
            }
        }
        .sheet(isPresented: $showDetails) {
            if let walker = viewModel.selectedWalker {
                NavigationStack {
                    WalkerDetailView(viewModel: WalkerDetailViewModel(walker: walker, currentUser: user))
                }
            }
        }
        .overlay {
            if viewModel.isLoading { ProgressView() }
        }
        .alert(viewModel.error?.localizedDescription ?? "", isPresented: Binding(get: { viewModel.error != nil }, set: { if !$0 { viewModel.error = nil } })) {
            Button("OK", role: .cancel) { viewModel.error = nil }
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(MapSearchViewModel.Filter.allCases) { filter in
                    Button {
                        if viewModel.filters.contains(filter) {
                            viewModel.filters.remove(filter)
                        } else {
                            viewModel.filters.insert(filter)
                        }
                    } label: {
                        Text(filter.title)
                    }
                    .pillStyle(isSelected: viewModel.filters.contains(filter))
                }
            }
            .padding(12)
            .background(BlurView(style: .systemThinMaterial))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        }
    }
}

struct WalkerBottomSheet: View {
    let walker: Walker
    let onDismiss: () -> Void
    let onDetails: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Capsule().frame(width: 40, height: 5).foregroundColor(.secondary)
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(walker.userId.uuidString.prefix(6))
                        .font(.title2)
                        .bold()
                    Text("₽\(Int(walker.ratePerHour))/ч • ⭐️\(String(format: "%.1f", walker.ratingAvg))")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action: onDismiss) { Image(systemName: "xmark.circle.fill").font(.title2) }
            }
            Button(NSLocalizedString("walker.book", comment: "")) {
                // TODO: integrate booking flow from bottom sheet
            }
            .buttonStyle(.borderedProminent)

            Button(NSLocalizedString("walker.detail", comment: ""), action: onDetails)
                .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).fill(Color(.systemBackground)))
        .padding()
    }
}

struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
