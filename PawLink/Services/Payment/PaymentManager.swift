import Foundation
import PassKit

final class PaymentManager: NSObject, ObservableObject {
    private let service: PaymentService

    init(service: PaymentService = MockPaymentService()) {
        self.service = service
    }

    func startApplePay(for booking: Booking, completion: @escaping (Result<Void, AppError>) -> Void) {
        service.presentApplePay(for: booking, completion: completion)
    }

    func price(for walker: Walker, duration: Int, options: [BookingOption]) -> Double {
        service.calculatePrice(for: walker, duration: duration, options: options)
    }
}

final class MockPaymentService: NSObject, PaymentService, PKPaymentAuthorizationControllerDelegate {
    func presentApplePay(for booking: Booking, completion: @escaping (Result<Void, AppError>) -> Void) {
        // Simulated success callback
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(.success(()))
        }
    }

    func calculatePrice(for walker: Walker, duration: Int, options: [BookingOption]) -> Double {
        let base = walker.ratePerHour * Double(duration) / 60
        let extras = options.reduce(0) { result, option in
            switch option {
            case .washPaws: return result + 150
            case .photoReport: return result + 200
            }
        }
        return base + extras
    }
}
