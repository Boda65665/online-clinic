import Foundation
import MapKit

@MainActor
final class MapSearchViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 55.751244, longitude: 37.618423), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    @Published var walkers: [WalkerAnnotation] = []

    private let walkerService: WalkerService
    private let locationService: LocationService
    private let analytics: AnalyticsService

    init(walkerService: WalkerService, locationService: LocationService, analytics: AnalyticsService) {
        self.walkerService = walkerService
        self.locationService = locationService
        self.analytics = analytics
    }

    func load() async {
        do {
            let walkerModels = try await walkerService.fetchWalkers(filter: .init())
            walkers = walkerModels.map { WalkerAnnotation(walker: $0) }
            await analytics.track(event: .searchOpened)
        } catch {
            print("Failed to load walkers: \(error)")
        }
    }
}

struct WalkerAnnotation: Identifiable {
    let id = UUID()
    let walker: Walker
    var coordinate: CLLocationCoordinate2D { walker.serviceArea.center }
}
