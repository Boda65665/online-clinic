import Foundation
import SwiftData

@Model
final class Message {
    @Attribute(.unique) var id: UUID
    var chatId: UUID
    var senderId: UUID
    var content: String
    var createdAt: Date
    var isRead: Bool

    init(id: UUID, chatId: UUID, senderId: UUID, content: String, createdAt: Date, isRead: Bool) {
        self.id = id
        self.chatId = chatId
        self.senderId = senderId
        self.content = content
        self.createdAt = createdAt
        self.isRead = isRead
    }
}
