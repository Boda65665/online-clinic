import Foundation
import CoreLocation

enum MockData {
    private static var walkerCache: [Walker]?
    private static var petCache: [UUID: [Pet]] = [:]

    static let previewOwner = User(id: UUID(), role: .owner, name: "Анна", email: "anna@example.com", phone: "+79995553322", avatarURL: nil, createdAt: Date())

    static func owners() -> [User] {
        [previewOwner,
         User(id: UUID(), role: .owner, name: "Иван", email: "ivan@example.com", phone: "+79997774455", avatarURL: nil, createdAt: Date())]
    }

    static func walkers(owner: User? = nil) -> [Walker] {
        if let cache = walkerCache { return cache }
        let coordinates = [CLLocationCoordinate2D(latitude: 55.751244, longitude: 37.618423),
                           CLLocationCoordinate2D(latitude: 55.760186, longitude: 37.618711),
                           CLLocationCoordinate2D(latitude: 55.743791, longitude: 37.650559),
                           CLLocationCoordinate2D(latitude: 55.73092, longitude: 37.60053),
                           CLLocationCoordinate2D(latitude: 55.7407, longitude: 37.5901)]

        let result = (0..<5).map { index in
            let walkerId = UUID()
            return Walker(id: walkerId,
                   userId: UUID(),
                   ratePerHour: Decimal(700 + index * 50),
                   serviceArea: .init(center: coordinates[index % coordinates.count], radius: 2_000),
                   bio: "Опыт выгульщика \(index + 1) лет. Люблю животных и использую позитивное подкрепление.",
                   ratingAvg: 4.5 + Double(index) * 0.1,
                   reviewsCount: 12 + index,
                   isVerified: index % 2 == 0,
                   tags: ["Фотоотчет", "GPS", "Дрессировка"],
                   availability: MockData.timeSlots(for: index, walkerId: walkerId))
        }
        walkerCache = result
        return result
    }

    static func pets(owner: User) -> [Pet] {
        if let cached = petCache[owner.id] { return cached }
        let pets = [Pet(id: UUID(), ownerId: owner.id, name: "Барсик", species: "Кот", breed: "Британец", ageYears: 4, weightKg: 5.2, notes: "Боится громких звуков", vaccinations: ["Бешенство"], avatarURL: nil),
         Pet(id: UUID(), ownerId: owner.id, name: "Рекс", species: "Собака", breed: "Лабрадор", ageYears: 6, weightKg: 28.0, notes: "Любит плавать", vaccinations: ["Чумка", "Парвовирус"], avatarURL: nil)]
        petCache[owner.id] = pets
        return pets
    }

    static func bookings(owner: User, walker: Walker, pet: Pet) -> [Booking] {
        let start = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        return [Booking(id: UUID(), ownerId: owner.id, walkerId: walker.id, petId: pet.id, address: "Москва, ул. Тверская, д. 1", start: start, durationMin: 60, options: [.washPaws], price: Decimal(1200), status: .pending, chatId: UUID(), createdAt: Date())]
    }

    static func timeSlots(for index: Int, walkerId: UUID) -> [TimeSlot] {
        (0..<7).flatMap { day -> [TimeSlot] in
            let baseDate = Calendar.current.date(byAdding: .day, value: day, to: Date()) ?? Date()
            return [0, 2, 4].map { hourOffset -> TimeSlot in
                let start = Calendar.current.date(bySettingHour: 9 + hourOffset, minute: 0, second: 0, of: baseDate) ?? baseDate
                let end = Calendar.current.date(byAdding: .minute, value: 60, to: start) ?? start
                return TimeSlot(id: UUID(), walkerId: walkerId, start: start, end: end, isBooked: Bool.random() && day == 0)
            }
        }
        walkerCache = result
        return result
    }

    static func cremationOrders(owner: User, pets: [Pet]) -> [CremationOrder] {
        let now = Date()
        return [
            CremationOrder(id: UUID(), ownerId: owner.id, petId: pets.first?.id, weightKg: 4.5, pickupAddress: "Москва, ул. Арбат", contactName: owner.name, contactPhone: owner.phone ?? "+79990000000", contactEmail: owner.email ?? "owner@example.com", package: .standard, wishes: "Урна с гравировкой", pickupAt: Calendar.current.date(byAdding: .day, value: 2, to: now) ?? now, status: .scheduled, certificatePDFURL: nil, createdAt: now, updatedAt: now),
            CremationOrder(id: UUID(), ownerId: owner.id, petId: pets.last?.id, weightKg: 12.0, pickupAddress: "Москва, ул. Крымский Вал", contactName: owner.name, contactPhone: owner.phone ?? "+79990000000", contactEmail: owner.email ?? "owner@example.com", package: .premium, wishes: "Кремировать индивидуально", pickupAt: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now, status: .completed, certificatePDFURL: nil, createdAt: now, updatedAt: now)
        ]
    }

    static func messages(chatId: UUID, owner: User, walker: Walker) -> [Message] {
        [Message(id: UUID(), chatId: chatId, senderId: owner.id, content: "Здравствуйте! Готовы ли вы завтра в 10?", createdAt: Date(), isRead: true),
         Message(id: UUID(), chatId: chatId, senderId: walker.userId, content: "Да, доступен. Подтвердите бронь, пожалуйста.", createdAt: Date(), isRead: false),
         Message(id: UUID(), chatId: chatId, senderId: owner.id, content: "Спасибо!", createdAt: Date(), isRead: false)]
    }

    static func reviews(owner: User, walker: Walker) -> [Review] {
        [Review(id: UUID(), bookingId: UUID(), ownerId: owner.id, walkerId: walker.id, rating: 5, comment: "Отличная прогулка!", createdAt: Date()),
         Review(id: UUID(), bookingId: UUID(), ownerId: owner.id, walkerId: walker.id, rating: 4, comment: "Все понравилось", createdAt: Date()),
         Review(id: UUID(), bookingId: UUID(), ownerId: owner.id, walkerId: walker.id, rating: 3, comment: "Есть куда расти", createdAt: Date())]
    }
}
