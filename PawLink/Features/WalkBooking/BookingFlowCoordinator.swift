import SwiftUI

final class BookingFlowCoordinator: ObservableObject {
    @Published var path: [BookingStep] = []
    @Published var booking: Booking?

    private let input: BookingFlowInput
    private let services: ServiceRegistry

    init(input: BookingFlowInput, services: ServiceRegistry) {
        self.input = input
        self.services = services
    }

    func start() -> some View {
        NavigationStack(path: $path) {
            SlotPickerView(viewModel: SlotPickerViewModel(walker: input.walker, bookingService: services.bookings, analytics: services.analytics)) { slot in
                path.append(.details(slot))
            }
            .navigationDestination(for: BookingStep.self) { step in
                switch step {
                case .details(let slot):
                    BookingDetailsView(viewModel: BookingDetailsViewModel(owner: input.owner, walker: input.walker, slot: slot, bookingService: services.bookings, notificationService: services.notifications, analytics: services.analytics, pets: MockData.pets(owner: input.owner))) { booking in
                        self.booking = booking
                        path.append(.payment(booking))
                    }
                case .payment(let booking):
                    PaymentView(viewModel: PaymentViewModel(booking: booking, paymentManager: PaymentManager(service: services.payment), analytics: services.analytics)) { updated in
                        self.booking = updated
                        path.append(.status(updated))
                    }
                case .status(let booking):
                    BookingStatusView(viewModel: BookingStatusViewModel(booking: booking))
                }
            }
        }
    }
}

enum BookingStep: Hashable {
    case details(TimeSlot)
    case payment(Booking)
    case status(Booking)
}


struct BookingFlowContainer: View {
    @StateObject var coordinator: BookingFlowCoordinator

    init(coordinator: BookingFlowCoordinator) {
        _coordinator = StateObject(wrappedValue: coordinator)
    }

    var body: some View {
        coordinator.start()
    }
}
