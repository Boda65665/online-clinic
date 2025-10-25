import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var role: UserRole
    var name: String
    var email: String
    var phone: String
    var avatarURL: URL?
    var createdAt: Date

    init(id: UUID = UUID(),
         role: UserRole,
         name: String,
         email: String,
         phone: String,
         avatarURL: URL? = nil,
         createdAt: Date = .now) {
        self.id = id
        self.role = role
        self.name = name
        self.email = email
        self.phone = phone
        self.avatarURL = avatarURL
        self.createdAt = createdAt
    }
}

enum UserRole: String, Codable, CaseIterable, Identifiable {
    case owner
    case walker

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .owner: return NSLocalizedString("role.owner", comment: "Owner role")
        case .walker: return NSLocalizedString("role.walker", comment: "Walker role")
        }
    }
}

@Model
final class Pet {
    @Attribute(.unique) var id: UUID
    var ownerId: UUID
    var name: String
    var species: String
    var breed: String
    var ageYears: Int
    var weightKg: Double
    var notes: String
    var vaccinations: [String]
    var avatarURL: URL?

    init(id: UUID = UUID(),
         ownerId: UUID,
         name: String,
         species: String,
         breed: String,
         ageYears: Int,
         weightKg: Double,
         notes: String,
         vaccinations: [String],
         avatarURL: URL? = nil) {
        self.id = id
        self.ownerId = ownerId
        self.name = name
        self.species = species
        self.breed = breed
        self.ageYears = ageYears
        self.weightKg = weightKg
        self.notes = notes
        self.vaccinations = vaccinations
        self.avatarURL = avatarURL
    }
}

@Model
final class Walker {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var ratePerHour: Double
    var serviceArea: ServiceArea
    var bio: String
    var ratingAvg: Double
    var reviewsCount: Int
    var isVerified: Bool
    var tags: [String]
    var availability: [TimeSlot]

    init(id: UUID = UUID(),
         userId: UUID,
         ratePerHour: Double,
         serviceArea: ServiceArea,
         bio: String,
         ratingAvg: Double,
         reviewsCount: Int,
         isVerified: Bool,
         tags: [String],
         availability: [TimeSlot]) {
        self.id = id
        self.userId = userId
        self.ratePerHour = ratePerHour
        self.serviceArea = serviceArea
        self.bio = bio
        self.ratingAvg = ratingAvg
        self.reviewsCount = reviewsCount
        self.isVerified = isVerified
        self.tags = tags
        self.availability = availability
    }
}

struct ServiceArea: Codable, Hashable {
    var centerLatitude: Double
    var centerLongitude: Double
    var radiusMeters: Double
}

@Model
final class TimeSlot: Identifiable {
    @Attribute(.unique) var id: UUID
    var walkerId: UUID
    var start: Date
    var end: Date
    var isBooked: Bool

    init(id: UUID = UUID(),
         walkerId: UUID,
         start: Date,
         end: Date,
         isBooked: Bool) {
        self.id = id
        self.walkerId = walkerId
        self.start = start
        self.end = end
        self.isBooked = isBooked
    }
}

@Model
final class Booking {
    @Attribute(.unique) var id: UUID
    var ownerId: UUID
    var walkerId: UUID
    var petId: UUID
    var address: String
    var start: Date
    var durationMin: Int
    var options: [BookingOption]
    var price: Double
    var status: BookingStatus
    var chatId: UUID
    var createdAt: Date

    init(id: UUID = UUID(),
         ownerId: UUID,
         walkerId: UUID,
         petId: UUID,
         address: String,
         start: Date,
         durationMin: Int,
         options: [BookingOption],
         price: Double,
         status: BookingStatus,
         chatId: UUID,
         createdAt: Date = .now) {
        self.id = id
        self.ownerId = ownerId
        self.walkerId = walkerId
        self.petId = petId
        self.address = address
        self.start = start
        self.durationMin = durationMin
        self.options = options
        self.price = price
        self.status = status
        self.chatId = chatId
        self.createdAt = createdAt
    }
}

enum BookingOption: String, Codable, CaseIterable, Identifiable {
    case washPaws
    case photoReport

    var id: String { rawValue }

    var title: String {
        switch self {
        case .washPaws: return NSLocalizedString("booking.option.wash", comment: "")
        case .photoReport: return NSLocalizedString("booking.option.photo", comment: "")
        }
    }
}

enum BookingStatus: String, Codable, CaseIterable, Identifiable {
    case pending
    case accepted
    case declined
    case active
    case completed
    case paid
    case cancelled

    var id: String { rawValue }

    var timelineTitle: String {
        switch self {
        case .pending: return NSLocalizedString("booking.status.pending", comment: "")
        case .accepted: return NSLocalizedString("booking.status.accepted", comment: "")
        case .declined: return NSLocalizedString("booking.status.declined", comment: "")
        case .active: return NSLocalizedString("booking.status.active", comment: "")
        case .completed: return NSLocalizedString("booking.status.completed", comment: "")
        case .paid: return NSLocalizedString("booking.status.paid", comment: "")
        case .cancelled: return NSLocalizedString("booking.status.cancelled", comment: "")
        }
    }
}

@Model
final class CremationOrder {
    @Attribute(.unique) var id: UUID
    var ownerId: UUID
    var petId: UUID
    var weightKg: Double
    var pickupAddress: String
    var contactName: String
    var contactPhone: String
    var contactEmail: String
    var packageType: CremationPackage
    var wishes: String?
    var pickupAt: Date
    var status: CremationStatus
    var certificatePDFURL: URL?
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(),
         ownerId: UUID,
         petId: UUID,
         weightKg: Double,
         pickupAddress: String,
         contactName: String,
         contactPhone: String,
         contactEmail: String,
         packageType: CremationPackage,
         wishes: String?,
         pickupAt: Date,
         status: CremationStatus,
         certificatePDFURL: URL? = nil,
         createdAt: Date = .now,
         updatedAt: Date = .now) {
        self.id = id
        self.ownerId = ownerId
        self.petId = petId
        self.weightKg = weightKg
        self.pickupAddress = pickupAddress
        self.contactName = contactName
        self.contactPhone = contactPhone
        self.contactEmail = contactEmail
        self.packageType = packageType
        self.wishes = wishes
        self.pickupAt = pickupAt
        self.status = status
        self.certificatePDFURL = certificatePDFURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum CremationPackage: String, Codable, CaseIterable, Identifiable {
    case econom
    case standard
    case premium

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .econom: return NSLocalizedString("cremation.package.econom", comment: "")
        case .standard: return NSLocalizedString("cremation.package.standard", comment: "")
        case .premium: return NSLocalizedString("cremation.package.premium", comment: "")
        }
    }
}

enum CremationStatus: String, Codable, CaseIterable, Identifiable {
    case created
    case scheduled
    case picked_up
    case in_progress
    case completed
    case delivered
    case certificate_ready

    var id: String { rawValue }

    var timelineTitle: String {
        switch self {
        case .created: return NSLocalizedString("cremation.status.created", comment: "")
        case .scheduled: return NSLocalizedString("cremation.status.scheduled", comment: "")
        case .picked_up: return NSLocalizedString("cremation.status.picked_up", comment: "")
        case .in_progress: return NSLocalizedString("cremation.status.in_progress", comment: "")
        case .completed: return NSLocalizedString("cremation.status.completed", comment: "")
        case .delivered: return NSLocalizedString("cremation.status.delivered", comment: "")
        case .certificate_ready: return NSLocalizedString("cremation.status.certificate_ready", comment: "")
        }
    }
}

@Model
final class Message {
    @Attribute(.unique) var id: UUID
    var chatId: UUID
    var senderId: UUID
    var content: String
    var createdAt: Date
    var isRead: Bool

    init(id: UUID = UUID(),
         chatId: UUID,
         senderId: UUID,
         content: String,
         createdAt: Date = .now,
         isRead: Bool = false) {
        self.id = id
        self.chatId = chatId
        self.senderId = senderId
        self.content = content
        self.createdAt = createdAt
        self.isRead = isRead
    }
}

@Model
final class Review {
    @Attribute(.unique) var id: UUID
    var bookingId: UUID
    var ownerId: UUID
    var walkerId: UUID
    var rating: Int
    var comment: String
    var createdAt: Date

    init(id: UUID = UUID(),
         bookingId: UUID,
         ownerId: UUID,
         walkerId: UUID,
         rating: Int,
         comment: String,
         createdAt: Date = .now) {
        self.id = id
        self.bookingId = bookingId
        self.ownerId = ownerId
        self.walkerId = walkerId
        self.rating = rating
        self.comment = comment
        self.createdAt = createdAt
    }
}
