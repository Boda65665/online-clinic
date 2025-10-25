import Foundation
import SwiftData

enum CremationPackage: String, Codable, CaseIterable, Identifiable {
    case econom
    case standard
    case premium

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .econom: return "cremation_package_econom".localized
        case .standard: return "cremation_package_standard".localized
        case .premium: return "cremation_package_premium".localized
        }
    }
}

enum CremationStatus: String, Codable, CaseIterable {
    case created
    case scheduled
    case picked_up
    case in_progress
    case completed
    case delivered
    case certificate_ready
}

@Model
final class CremationOrder {
    @Attribute(.unique) var id: UUID
    var ownerId: UUID
    var petId: UUID?
    var weightKg: Double
    var pickupAddress: String
    var contactName: String
    var contactPhone: String
    var contactEmail: String
    var package: CremationPackage
    var wishes: String?
    var pickupAt: Date
    var status: CremationStatus
    var certificatePDFURL: URL?
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID, ownerId: UUID, petId: UUID?, weightKg: Double, pickupAddress: String, contactName: String, contactPhone: String, contactEmail: String, package: CremationPackage, wishes: String?, pickupAt: Date, status: CremationStatus, certificatePDFURL: URL?, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.ownerId = ownerId
        self.petId = petId
        self.weightKg = weightKg
        self.pickupAddress = pickupAddress
        self.contactName = contactName
        self.contactPhone = contactPhone
        self.contactEmail = contactEmail
        self.package = package
        self.wishes = wishes
        self.pickupAt = pickupAt
        self.status = status
        self.certificatePDFURL = certificatePDFURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
