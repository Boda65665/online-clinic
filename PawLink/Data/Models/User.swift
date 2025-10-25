import Foundation
import SwiftData

enum UserRole: String, Codable, CaseIterable {
    case owner
    case walker
}

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var role: UserRole
    var name: String
    var email: String?
    var phone: String?
    var avatarURL: URL?
    var createdAt: Date

    init(id: UUID, role: UserRole, name: String, email: String?, phone: String?, avatarURL: URL?, createdAt: Date) {
        self.id = id
        self.role = role
        self.name = name
        self.email = email
        self.phone = phone
        self.avatarURL = avatarURL
        self.createdAt = createdAt
    }
}
