import Foundation
import PassKit

protocol PaymentProcessing {
    func startPayment(for booking: Booking) async throws
}

final class PaymentManager: PaymentProcessing {
    private let service: PaymentService

    init(service: PaymentService) {
        self.service = service
    }

    func startPayment(for booking: Booking) async throws {
        // TODO: Integrate real Apple Pay with PKPaymentAuthorizationController.
        try await service.makePayment(for: booking)
    }
}
