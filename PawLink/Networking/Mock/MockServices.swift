import Foundation
import Combine
import CoreLocation

actor MockAuthService: AuthService {
    private(set) var currentUser: User?
    private var storedUsers: [User] = []

    func prepareInitialData() async throws {
        storedUsers = MockData.owners()
        currentUser = storedUsers.first
    }

    func signInWithApple() async throws -> User {
        guard let user = storedUsers.first else { throw AppError(title: "auth_error".localized, message: "no_users".localized) }
        currentUser = user
        return user
    }

    func signIn(email: String) async throws -> User {
        if let user = storedUsers.first(where: { $0.email == email }) {
            currentUser = user
            return user
        }
        let newUser = User(id: UUID(), role: .owner, name: email.components(separatedBy: "@").first ?? "User", email: email, phone: nil, avatarURL: nil, createdAt: Date())
        storedUsers.append(newUser)
        currentUser = newUser
        return newUser
    }

    func signOut() async throws {
        currentUser = nil
    }

    func restoreSession() async throws {
        currentUser = storedUsers.first
    }
}

actor MockWalkerService: WalkerService {
    private var walkers: [Walker] = []

    func prepareInitialData() async throws {
        walkers = MockData.walkers()
    }

    func fetchWalkers(filter: WalkerFilter) async throws -> [Walker] {
        walkers
            .filter { walker in
                var matches = true
                if let maxPrice = filter.maxPrice {
                    matches = matches && walker.ratePerHour <= maxPrice
                }
                if let minRating = filter.minRating {
                    matches = matches && walker.ratingAvg >= minRating
                }
                return matches
            }
    }
}

actor MockBookingService: BookingService {
    private var bookings: [Booking] = []

    func prepareInitialData() async throws {
        guard let owner = MockData.owners().first,
              let walker = MockData.walkers().first,
              let pet = MockData.pets(owner: owner).first else { return }
        bookings = MockData.bookings(owner: owner, walker: walker, pet: pet)
    }

    func fetchBookings(for userId: UUID) async throws -> [Booking] {
        bookings.filter { $0.ownerId == userId }
    }

    func createBooking(_ request: BookingRequest) async throws -> Booking {
        let booking = Booking(id: UUID(), ownerId: request.ownerId, walkerId: request.walkerId, petId: request.petId, address: request.address, start: request.start, durationMin: request.duration, options: request.options, price: Decimal(1000), status: .pending, chatId: UUID(), createdAt: Date())
        bookings.append(booking)
        return booking
    }

    func updateStatus(bookingId: UUID, status: BookingStatus) async throws -> Booking {
        guard let index = bookings.firstIndex(where: { $0.id == bookingId }) else {
            throw AppError(title: "booking_not_found".localized, message: "booking_not_found".localized)
        }
        bookings[index].status = status
        return bookings[index]
    }
}

actor MockChatService: ChatService {
    private var messagesStore: [UUID: [Message]] = [:]
    private var chats: [ChatSummary] = []

    func prepareInitialData() async throws {
        guard let owner = MockData.owners().first,
              let walker = MockData.walkers().first else { return }
        let chatId = UUID()
        let messages = MockData.messages(chatId: chatId, owner: owner, walker: walker)
        messagesStore[chatId] = messages
        chats = [ChatSummary(id: chatId, walker: walker, lastMessage: messages.last)]
    }

    func fetchChats(for userId: UUID) async throws -> [ChatSummary] {
        chats
    }

    func messages(for chatId: UUID) async throws -> [Message] {
        messagesStore[chatId] ?? []
    }

    func send(message: Message) async throws {
        var messages = messagesStore[message.chatId] ?? []
        messages.append(message)
        messagesStore[message.chatId] = messages
        if let index = chats.firstIndex(where: { $0.id == message.chatId }) {
            chats[index].lastMessage = message
        }
    }
}

actor MockCremationService: CremationService {
    private var orders: [CremationOrder] = []

    func prepareInitialData() async throws {
        guard let owner = MockData.owners().first else { return }
        let pets = MockData.pets(owner: owner)
        orders = MockData.cremationOrders(owner: owner, pets: pets)
    }

    func fetchOrders(for ownerId: UUID) async throws -> [CremationOrder] {
        orders.filter { $0.ownerId == ownerId }
    }

    func createOrder(_ input: CremationInput) async throws -> CremationOrder {
        let order = CremationOrder(id: UUID(), ownerId: input.ownerId, petId: input.petId, weightKg: input.weightKg, pickupAddress: input.pickupAddress, contactName: input.contactName, contactPhone: input.contactPhone, contactEmail: input.contactEmail, package: input.package, wishes: input.wishes, pickupAt: input.pickupAt, status: .created, certificatePDFURL: nil, createdAt: Date(), updatedAt: Date())
        orders.append(order)
        return order
    }

    func update(order: CremationOrder) async throws -> CremationOrder {
        guard let index = orders.firstIndex(where: { $0.id == order.id }) else { throw AppError(title: "order_not_found".localized, message: "order_not_found".localized) }
        orders[index] = order
        return order
    }
}

struct MockPaymentService: PaymentService {
    func makePayment(for booking: Booking) async throws {
        // Simulate success
    }
}

struct MockNotificationService: NotificationService {
    func requestAuthorization() async throws {}

    func scheduleLocalNotification(at date: Date, title: String, body: String, identifier: String) async throws {}
}

struct MockAnalyticsService: AnalyticsService {
    func track(event: AnalyticsEvent) async {
        // TODO: Integrate with Firebase/CloudKit when available.
    }
}

struct MockLocationService: LocationService {
    var authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse

    func requestPermission() async {}

    func currentLocation() async -> CLLocationCoordinate2D? {
        CLLocationCoordinate2D(latitude: 55.751244, longitude: 37.618423)
    }
}
