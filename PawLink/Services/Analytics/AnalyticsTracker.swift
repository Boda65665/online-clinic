import Foundation

final class AnalyticsTracker {
    private let service: AnalyticsService

    init(service: AnalyticsService) {
        self.service = service
    }

    func track(_ event: AnalyticsEvent) async {
        await service.track(event: event)
    }
}
