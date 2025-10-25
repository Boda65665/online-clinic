import Foundation
import SwiftData

enum AppModelContainer {
    static let shared = AppModelContainer()

    let container: ModelContainer

    init(inMemory: Bool = true) {
        let schema = Schema([
            User.self,
            Pet.self,
            Walker.self,
            TimeSlot.self,
            Booking.self,
            CremationOrder.self,
            Message.self,
            Review.self
        ])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        do {
            container = try ModelContainer(for: schema, configurations: configuration)
            try SampleDataSeeder(container: container).seedIfNeeded()
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }
}

final class SampleDataSeeder {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    func seedIfNeeded() throws {
        let context = ModelContext(container)
        let fetch = FetchDescriptor<User>()
        if let count = try? context.fetch(fetch).count, count > 0 {
            return
        }

        // MARK: Sample Users
        let owner1 = User(role: .owner, name: "Анна Петрова", email: "anna@example.com", phone: "+79990001122")
        let owner2 = User(role: .owner, name: "Иван Смирнов", email: "ivan@example.com", phone: "+79990003344")
        let walkerUsers = [
            User(role: .walker, name: "Алексей", email: "alexey@pawlink.com", phone: "+79995550101"),
            User(role: .walker, name: "Мария", email: "maria@pawlink.com", phone: "+79995550202"),
            User(role: .walker, name: "Дмитрий", email: "dmitry@pawlink.com", phone: "+79995550303"),
            User(role: .walker, name: "Елена", email: "elena@pawlink.com", phone: "+79995550404"),
            User(role: .walker, name: "Роман", email: "roman@pawlink.com", phone: "+79995550505")
        ]

        [owner1, owner2].forEach { context.insert($0) }
        walkerUsers.forEach { context.insert($0) }

        // MARK: Pets
        let pets = [
            Pet(ownerId: owner1.id, name: "Боня", species: "Собака", breed: "Бигль", ageYears: 4, weightKg: 12.0, notes: "Любит игрушки", vaccinations: ["Бешенство"]),
            Pet(ownerId: owner1.id, name: "Марс", species: "Собака", breed: "Лабрадор", ageYears: 2, weightKg: 28.5, notes: "Активный", vaccinations: ["Чумка"]),
            Pet(ownerId: owner2.id, name: "Снежок", species: "Кот", breed: "Сибирский", ageYears: 5, weightKg: 6.2, notes: "Спокойный", vaccinations: [])
        ]
        pets.forEach { context.insert($0) }

        // MARK: Walkers
        let calendar = Calendar.current
        let baseDate = calendar.startOfDay(for: .now)
        let timeSlots: [TimeSlot] = walkerUsers.enumerated().flatMap { index, walkerUser in
            (0..<7).flatMap { day in
                (0..<3).map { slotIndex -> TimeSlot in
                    let start = calendar.date(byAdding: .day, value: day, to: baseDate)!
                        .addingTimeInterval(Double(9 + slotIndex * 2) * 3600)
                    let end = start.addingTimeInterval(60 * 60)
                    return TimeSlot(walkerId: walkerUser.id, start: start, end: end, isBooked: false)
                }
            }
        }
        timeSlots.forEach { context.insert($0) }

        let walkers: [Walker] = walkerUsers.map { walkerUser in
            Walker(userId: walkerUser.id,
                   ratePerHour: Double.random(in: 800...1500),
                   serviceArea: ServiceArea(centerLatitude: 55.751244, centerLongitude: 37.618423, radiusMeters: 3000 + Double.random(in: 0...2000)),
                   bio: "Опыт выгульщика более 3 лет. Индивидуальный подход и любовь к животным.",
                   ratingAvg: Double.random(in: 4.2...4.9),
                   reviewsCount: Int.random(in: 12...120),
                   isVerified: Bool.random(),
                   tags: ["Опытный", "Фотоотчет", "Мойка лап"],
                   availability: timeSlots.filter { $0.walkerId == walkerUser.id })
        }
        walkers.forEach { context.insert($0) }

        // MARK: Bookings
        let sampleBooking = Booking(ownerId: owner1.id,
                                    walkerId: walkers[0].id,
                                    petId: pets[0].id,
                                    address: "Москва, Тверская 10",
                                    start: baseDate.addingTimeInterval(3600 * 14),
                                    durationMin: 60,
                                    options: [.photoReport],
                                    price: 1200,
                                    status: .accepted,
                                    chatId: UUID())
        context.insert(sampleBooking)

        // MARK: Cremation Orders
        let order1 = CremationOrder(ownerId: owner1.id,
                                    petId: pets[0].id,
                                    weightKg: 12.0,
                                    pickupAddress: "Москва, ул. Пушкина 1",
                                    contactName: "Анна Петрова",
                                    contactPhone: "+79990001122",
                                    contactEmail: "anna@example.com",
                                    packageType: .standard,
                                    wishes: "Индивидуальная кремация",
                                    pickupAt: baseDate.addingTimeInterval(3600 * 48),
                                    status: .scheduled)
        let order2 = CremationOrder(ownerId: owner2.id,
                                    petId: pets[2].id,
                                    weightKg: 6.5,
                                    pickupAddress: "Москва, ул. Ленина 3",
                                    contactName: "Иван Смирнов",
                                    contactPhone: "+79990003344",
                                    contactEmail: "ivan@example.com",
                                    packageType: .econom,
                                    wishes: "Общий крематорий",
                                    pickupAt: baseDate.addingTimeInterval(3600 * 72),
                                    status: .in_progress)
        context.insert(order1)
        context.insert(order2)

        // MARK: Messages
        let messages = (0..<5).map { index in
            Message(chatId: sampleBooking.chatId,
                    senderId: index % 2 == 0 ? owner1.id : walkers[0].userId,
                    content: index % 2 == 0 ? "Здравствуйте! Когда сможете начать прогулку?" : "Добрый день! Приеду через 10 минут.",
                    createdAt: baseDate.addingTimeInterval(Double(index) * 600))
        }
        messages.forEach { context.insert($0) }

        // MARK: Reviews
        let reviews = [
            Review(bookingId: sampleBooking.id, ownerId: owner1.id, walkerId: walkers[0].id, rating: 5, comment: "Отличная прогулка!"),
            Review(bookingId: sampleBooking.id, ownerId: owner1.id, walkerId: walkers[0].id, rating: 4, comment: "Все понравилось."),
            Review(bookingId: sampleBooking.id, ownerId: owner1.id, walkerId: walkers[0].id, rating: 5, comment: "Рекомендую." )
        ]
        reviews.forEach { context.insert($0) }

        try context.save()
    }
}
