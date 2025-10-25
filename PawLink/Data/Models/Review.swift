import Foundation
import SwiftData

@Model
final class Review {
    @Attribute(.unique) var id: UUID
    var bookingId: UUID
    var ownerId: UUID
    var walkerId: UUID
    var rating: Int
    var comment: String
    var createdAt: Date

    init(id: UUID, bookingId: UUID, ownerId: UUID, walkerId: UUID, rating: Int, comment: String, createdAt: Date) {
        self.id = id
        self.bookingId = bookingId
        self.ownerId = ownerId
        self.walkerId = walkerId
        self.rating = rating
        self.comment = comment
        self.createdAt = createdAt
    }
}
