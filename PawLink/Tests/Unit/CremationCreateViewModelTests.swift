import XCTest
@testable import PawLink

final class CremationCreateViewModelTests: XCTestCase {
    func testInvalidEmailProducesError() async {
        let viewModel = CremationCreateViewModel(service: MockCremationService(), analytics: MockAnalyticsService(), notificationService: MockNotificationService(), validation: ValidationService())
        viewModel.weightText = "3.4"
        viewModel.address = "Address"
        viewModel.contactName = "Name"
        viewModel.contactPhone = "+70000000000"
        viewModel.contactEmail = "bad"
        viewModel.consentAccepted = true
        let order = await viewModel.submit(owner: MockData.previewOwner)
        XCTAssertNil(order)
        XCTAssertNotNil(viewModel.error)
    }
}
