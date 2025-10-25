import Foundation
import Combine
import CoreLocation

protocol AuthService {
    var currentUser: User? { get }
    func signInWithApple() async throws -> User
    func signIn(email: String) async throws -> User
    func signOut() async throws
    func restoreSession() async throws
    func prepareInitialData() async throws
}

protocol WalkerService {
    func fetchWalkers(filter: WalkerFilter) async throws -> [Walker]
    func prepareInitialData() async throws
}

struct WalkerFilter {
    var maxPrice: Decimal?
    var minRating: Double?
    var maxDistance: CLLocationDistance?
}

protocol BookingService {
    func fetchBookings(for userId: UUID) async throws -> [Booking]
    func createBooking(_ request: BookingRequest) async throws -> Booking
    func updateStatus(bookingId: UUID, status: BookingStatus) async throws -> Booking
    func prepareInitialData() async throws
}

struct BookingRequest {
    var ownerId: UUID
    var walkerId: UUID
    var petId: UUID
    var address: String
    var start: Date
    var duration: Int
    var options: [BookingOption]
}

protocol ChatService {
    func fetchChats(for userId: UUID) async throws -> [ChatSummary]
    func messages(for chatId: UUID) async throws -> [Message]
    func send(message: Message) async throws
    func prepareInitialData() async throws
}

struct ChatSummary: Identifiable {
    var id: UUID
    var walker: Walker
    var lastMessage: Message?
}

protocol CremationService {
    func fetchOrders(for ownerId: UUID) async throws -> [CremationOrder]
    func createOrder(_ input: CremationInput) async throws -> CremationOrder
    func update(order: CremationOrder) async throws -> CremationOrder
    func prepareInitialData() async throws
}

struct CremationInput {
    var ownerId: UUID
    var petId: UUID?
    var weightKg: Double
    var pickupAddress: String
    var contactName: String
    var contactPhone: String
    var contactEmail: String
    var package: CremationPackage
    var wishes: String?
    var pickupAt: Date
}

protocol PaymentService {
    func makePayment(for booking: Booking) async throws
}

protocol NotificationService {
    func requestAuthorization() async throws
    func scheduleLocalNotification(at date: Date, title: String, body: String, identifier: String) async throws
}

protocol AnalyticsService {
    func track(event: AnalyticsEvent) async
}

protocol LocationService {
    var authorizationStatus: CLAuthorizationStatus { get }
    func requestPermission() async
    func currentLocation() async -> CLLocationCoordinate2D?
}

enum AnalyticsEvent: String {
    case appLaunched
    case onboardingCompleted
    case searchOpened
    case bookingCreated
    case paymentConfirmed
    case reviewSubmitted
    case cremationCreated
}
