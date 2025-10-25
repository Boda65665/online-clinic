import Foundation
import CoreLocation

final class LocationManager: NSObject, ObservableObject {
    private let service: LocationService
    @Published var authorizationStatus: CLAuthorizationStatus

    init(service: LocationService) {
        self.service = service
        self.authorizationStatus = service.authorizationStatus
    }

    func requestPermission() async {
        await service.requestPermission()
    }

    func currentLocation() async -> CLLocationCoordinate2D? {
        await service.currentLocation()
    }
}
