import Foundation

@MainActor
final class BookingDetailsViewModel: ObservableObject {
    @Published var selectedPetId: UUID?
    @Published var address: String = ""
    @Published var duration: Int = 60
    @Published var options: Set<BookingOption> = []
    @Published var isLoading = false

    let pets: [Pet]
    private let owner: User
    private let walker: Walker
    private let slot: TimeSlot
    private let bookingService: BookingService
    private let notificationService: NotificationService
    private let analytics: AnalyticsService

    init(owner: User, walker: Walker, slot: TimeSlot, bookingService: BookingService, notificationService: NotificationService, analytics: AnalyticsService, pets: [Pet] = []) {
        self.owner = owner
        self.walker = walker
        self.slot = slot
        self.bookingService = bookingService
        self.notificationService = notificationService
        self.analytics = analytics
        self.pets = pets.isEmpty ? MockData.pets(owner: owner) : pets
    }

    func confirmBooking() async throws -> Booking {
        guard let petId = selectedPetId else {
            throw AppError(title: "booking_error".localized, message: "booking_pet_required".localized)
        }
        guard !address.isEmpty else {
            throw AppError(title: "booking_error".localized, message: "booking_address_required".localized)
        }
        isLoading = true
        defer { isLoading = false }
        let request = BookingRequest(ownerId: owner.id, walkerId: walker.id, petId: petId, address: address, start: slot.start, duration: duration, options: Array(options))
        let booking = try await bookingService.createBooking(request)
        try? await notificationService.scheduleLocalNotification(at: Calendar.current.date(byAdding: .hour, value: -1, to: booking.start) ?? booking.start, title: "booking_reminder_title".localized, body: "booking_reminder_body".localized, identifier: booking.id.uuidString)
        await analytics.track(event: .bookingCreated)
        return booking
    }
}
