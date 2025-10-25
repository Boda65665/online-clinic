import XCTest
@testable import PawLink

final class MapSearchViewModelTests: XCTestCase {
    func testLoadProducesAnnotations() async throws {
        let walkerService = MockWalkerService()
        try await walkerService.prepareInitialData()
        let viewModel = MapSearchViewModel(walkerService: walkerService, locationService: MockLocationService(), analytics: MockAnalyticsService())
        await viewModel.load()
        XCTAssertFalse(viewModel.walkers.isEmpty)
    }
}
