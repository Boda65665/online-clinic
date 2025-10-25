import Foundation

@MainActor
final class SlotPickerViewModel: ObservableObject {
    let walker: Walker
    @Published var slots: [TimeSlot] = []

    private let bookingService: BookingService
    private let analytics: AnalyticsService

    init(walker: Walker, bookingService: BookingService, analytics: AnalyticsService) {
        self.walker = walker
        self.bookingService = bookingService
        self.analytics = analytics
        self.slots = walker.availability
    }
}
