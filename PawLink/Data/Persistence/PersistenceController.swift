import Foundation
import SwiftData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    private init(inMemory: Bool = false) {
        let schema = Schema([User.self, Pet.self, Walker.self, Booking.self, CremationOrder.self, Message.self, Review.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create container: \(error)")
        }
    }
}
