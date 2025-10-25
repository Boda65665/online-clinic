import Foundation
import Combine

protocol AuthService {
    var currentUser: User? { get }
    var userPublisher: AnyPublisher<User?, Never> { get }
    func signIn(email: String?, completion: @escaping (Result<User, AppError>) -> Void)
    func signInWithApple(token: String, completion: @escaping (Result<User, AppError>) -> Void)
    func signOut()
}

protocol WalkerService {
    func fetchWalkers() -> AnyPublisher<[Walker], AppError>
    func fetchWalker(by id: UUID) -> AnyPublisher<Walker, AppError>
}

protocol BookingService {
    func fetchBookings(for user: User) -> AnyPublisher<[Booking], AppError>
    func createBooking(_ booking: Booking) -> AnyPublisher<Booking, AppError>
    func updateStatus(bookingId: UUID, status: BookingStatus) -> AnyPublisher<Booking, AppError>
}

protocol ChatService {
    func fetchMessages(chatId: UUID) -> AnyPublisher<[Message], AppError>
    func send(message: Message) -> AnyPublisher<Message, AppError>
}

protocol CremationService {
    func fetchOrders(ownerId: UUID) -> AnyPublisher<[CremationOrder], AppError>
    func create(order: CremationOrder) -> AnyPublisher<CremationOrder, AppError>
    func update(order: CremationOrder) -> AnyPublisher<CremationOrder, AppError>
}

protocol PaymentService {
    func presentApplePay(for booking: Booking, completion: @escaping (Result<Void, AppError>) -> Void)
    func calculatePrice(for walker: Walker, duration: Int, options: [BookingOption]) -> Double
}

protocol NotificationService {
    func requestAuthorization() async
    func scheduleReminder(for booking: Booking)
    func scheduleReminder(for order: CremationOrder)
}

protocol AnalyticsService {
    func track(event: AnalyticsEvent)
}

protocol LocationService {
    func requestAuthorization()
}
