import Foundation

@MainActor
final class PaymentViewModel: ObservableObject {
    @Published var isProcessing = false
    @Published var error: AppError?

    private(set) var booking: Booking
    private let paymentManager: PaymentProcessing
    private let analytics: AnalyticsService

    init(booking: Booking, paymentManager: PaymentProcessing, analytics: AnalyticsService) {
        self.booking = booking
        self.paymentManager = paymentManager
        self.analytics = analytics
    }

    func pay(completion: @escaping (Booking) -> Void) async {
        isProcessing = true
        defer { isProcessing = false }
        do {
            try await paymentManager.startPayment(for: booking)
            booking.status = .paid
            await analytics.track(event: .paymentConfirmed)
            completion(booking)
        } catch {
            self.error = AppError(error)
        }
    }
}
