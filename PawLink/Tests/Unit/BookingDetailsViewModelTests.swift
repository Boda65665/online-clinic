import XCTest
@testable import PawLink

final class BookingDetailsViewModelTests: XCTestCase {
    func testValidationFailsWithoutPet() async {
        let owner = MockData.previewOwner
        let walker = MockData.walkers().first!
        let slot = walker.availability.first!
        let viewModel = BookingDetailsViewModel(owner: owner, walker: walker, slot: slot, bookingService: MockBookingService(), notificationService: MockNotificationService(), analytics: MockAnalyticsService())
        viewModel.address = "Address"
        do {
            _ = try await viewModel.confirmBooking()
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }
}
