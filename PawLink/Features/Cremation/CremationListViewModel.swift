import Foundation

@MainActor
final class CremationListViewModel: ObservableObject {
    @Published var orders: [CremationOrder] = []
    @Published var selectedStatus: CremationStatus?

    private let service: CremationService
    private let analytics: AnalyticsService
    private let notificationService: NotificationService

    init(service: CremationService, analytics: AnalyticsService, notificationService: NotificationService) {
        self.service = service
        self.analytics = analytics
        self.notificationService = notificationService
    }

    func load(ownerId: UUID?) async {
        guard let ownerId else { return }
        do {
            var fetched = try await service.fetchOrders(for: ownerId)
            if let status = selectedStatus {
                fetched = fetched.filter { $0.status == status }
            }
            orders = fetched.sorted(by: { $0.pickupAt < $1.pickupAt })
        } catch {
            print("Failed to load cremation orders: \(error)")
        }
    }

    func select(status: CremationStatus?) {
        selectedStatus = status
    }
}
