import Foundation
import Combine

@MainActor
final class HomeOwnerViewModel: ObservableObject {
    @Published var walkers: [Walker] = []
    @Published var isLoading = false
    @Published var filter = WalkerFilter()

    private let walkerService: WalkerService
    private let bookingService: BookingService
    private let analytics: AnalyticsService
    private let coordinator: AppCoordinatorService

    init(walkerService: WalkerService, bookingService: BookingService, analytics: AnalyticsService, coordinator: AppCoordinatorService) {
        self.walkerService = walkerService
        self.bookingService = bookingService
        self.analytics = analytics
        self.coordinator = coordinator
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            walkers = try await walkerService.fetchWalkers(filter: filter)
            await analytics.track(event: .searchOpened)
        } catch {
            print("Failed to load walkers: \(error)")
        }
    }

    func openBooking(for walker: Walker, owner: User) {
        coordinator.openBooking(for: walker, owner: owner)
    }
}
