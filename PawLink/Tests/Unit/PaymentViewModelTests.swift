import XCTest
@testable import PawLink

final class PaymentViewModelTests: XCTestCase {
    func testPaymentMarksAsPaid() async {
        let booking = MockData.bookings(owner: MockData.previewOwner, walker: MockData.walkers().first!, pet: MockData.pets(owner: MockData.previewOwner).first!).first!
        let viewModel = PaymentViewModel(booking: booking, paymentManager: PaymentManager(service: MockPaymentService()), analytics: MockAnalyticsService())
        let expectation = expectation(description: "payment")
        await viewModel.pay { updated in
            XCTAssertEqual(updated.status, .paid)
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 1.0)
    }
}
