import XCTest
@testable import PawLink

final class OnboardingViewModelTests: XCTestCase {
    func testContinueFlow() async {
        let viewModel = OnboardingViewModel(authService: MockAuthService(), notificationService: MockNotificationService(), locationService: MockLocationService(), analytics: MockAnalyticsService()) {}
        XCTAssertEqual(viewModel.step, .role)
        viewModel.continueFlow()
        XCTAssertEqual(viewModel.step, .permissions)
    }
}
