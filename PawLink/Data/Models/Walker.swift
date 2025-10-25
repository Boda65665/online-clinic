import Foundation
import SwiftData

@Model
final class Walker {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var ratePerHour: Decimal
    var serviceArea: ServiceArea
    var bio: String
    var ratingAvg: Double
    var reviewsCount: Int
    var isVerified: Bool
    var tags: [String]
    var availability: [TimeSlot]

    init(id: UUID, userId: UUID, ratePerHour: Decimal, serviceArea: ServiceArea, bio: String, ratingAvg: Double, reviewsCount: Int, isVerified: Bool, tags: [String], availability: [TimeSlot]) {
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

struct TimeSlot: Codable, Hashable, Identifiable {
    var id: UUID
    var walkerId: UUID
    var start: Date
    var end: Date
    var isBooked: Bool
}
