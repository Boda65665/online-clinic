import Foundation

final class BookingStatusViewModel: ObservableObject {
    @Published var booking: Booking

    init(booking: Booking) {
        self.booking = booking
    }

    var timeline: [BookingStatus] {
        [.pending, .accepted, .active, .completed, .paid]
    }
}
