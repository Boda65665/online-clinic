import Foundation
import Combine
import SwiftData

final class MockBookingService: BookingService {
    private let context = ModelContext(AppModelContainer.shared.container)

    func fetchBookings(for user: User) -> AnyPublisher<[Booking], AppError> {
        Future { promise in
            let descriptor = FetchDescriptor<Booking>()
            do {
                let bookings = try self.context.fetch(descriptor)
                let filtered: [Booking]
                if user.role == .owner {
                    filtered = bookings.filter { $0.ownerId == user.id }
                } else {
                    let walkerDescriptor = FetchDescriptor<Walker>()
                    let walkerId = try self.context.fetch(walkerDescriptor).first(where: { $0.userId == user.id })?.id
                    filtered = bookings.filter { booking in
                        guard let walkerId else { return false }
                        return booking.walkerId == walkerId
                    }
                }
                promise(.success(filtered))
            } catch {
                promise(.failure(.unknown))
            }
        }
        .eraseToAnyPublisher()
    }

    func createBooking(_ booking: Booking) -> AnyPublisher<Booking, AppError> {
        Future { promise in
            self.context.insert(booking)
            do {
                try self.context.save()
                promise(.success(booking))
            } catch {
                promise(.failure(.unknown))
            }
        }
        .eraseToAnyPublisher()
    }

    func updateStatus(bookingId: UUID, status: BookingStatus) -> AnyPublisher<Booking, AppError> {
        Future { promise in
            let descriptor = FetchDescriptor<Booking>()
            do {
                if let booking = try self.context.fetch(descriptor).first(where: { $0.id == bookingId }) {
                    booking.status = status
                    try self.context.save()
                    promise(.success(booking))
                } else {
                    promise(.failure(.network(NSLocalizedString("booking.notfound", comment: ""))))
                }
            } catch {
                promise(.failure(.unknown))
            }
        }
        .eraseToAnyPublisher()
    }
}
