import Foundation
import CoreLocation

final class MockLocationService: NSObject, CLLocationManagerDelegate, LocationService {
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
}
