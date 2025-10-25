import Foundation
import CoreLocation

struct ServiceArea: Codable, Hashable {
    var center: CLLocationCoordinate2D
    var radius: Double
}

extension CLLocationCoordinate2D: @retroactive Codable {}

extension CLLocationCoordinate2D: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}
