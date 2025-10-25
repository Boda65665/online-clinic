import Foundation
import SwiftData

@Model
final class Pet {
    @Attribute(.unique) var id: UUID
    var ownerId: UUID
    var name: String
    var species: String
    var breed: String
    var ageYears: Int
    var weightKg: Double
    var notes: String?
    var vaccinations: [String]
    var avatarURL: URL?

    init(id: UUID, ownerId: UUID, name: String, species: String, breed: String, ageYears: Int, weightKg: Double, notes: String?, vaccinations: [String], avatarURL: URL?) {
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
