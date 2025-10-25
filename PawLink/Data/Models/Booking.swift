import Foundation
import SwiftData

enum BookingStatus: String, Codable, CaseIterable {
    case pending
    case accepted
    case declined
    case active
    case completed
    case paid
    case cancelled
}

enum BookingOption: String, Codable, CaseIterable, Identifiable {
    case washPaws
    case photoReport
    case treat

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .washPaws: return "booking_option_wash_paws".localized
        case .photoReport: return "booking_option_photo_report".localized
        case .treat: return "booking_option_treat".localized
        }
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
    var price: Decimal
    var status: BookingStatus
    var chatId: UUID
    var createdAt: Date

    init(id: UUID, ownerId: UUID, walkerId: UUID, petId: UUID, address: String, start: Date, durationMin: Int, options: [BookingOption], price: Decimal, status: BookingStatus, chatId: UUID, createdAt: Date) {
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
