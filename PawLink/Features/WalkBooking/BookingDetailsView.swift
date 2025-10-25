import SwiftUI

final class BookingDetailsViewModel: ObservableObject {
    @Published var selectedPet: Pet?
    @Published var address: String = ""
    @Published var duration: Int = 60
    @Published var options: Set<BookingOption> = []
    @Published var price: Double = 0
    @Published var showPayment = false
    @Published var error: AppError?

    let walker: Walker
    let user: User
    let slot: TimeSlot
    private let paymentManager = PaymentManager()

    init(walker: Walker, user: User, slot: TimeSlot) {
        self.walker = walker
        self.user = user
        self.slot = slot
    }

    func calculatePrice() {
        price = paymentManager.price(for: walker, duration: duration, options: Array(options))
    }

    func toggle(option: BookingOption) {
        if options.contains(option) {
            options.remove(option)
        } else {
            options.insert(option)
        }
        calculatePrice()
    }

    func proceedPayment(completion: @escaping (Result<Void, AppError>) -> Void) {
        let booking = Booking(ownerId: user.id,
                              walkerId: walker.id,
                              petId: selectedPet?.id ?? UUID(),
                              address: address,
                              start: slot.start,
                              durationMin: duration,
                              options: Array(options),
                              price: price,
                              status: .pending,
                              chatId: UUID())
        paymentManager.startApplePay(for: booking, completion: completion)
    }
}

struct BookingDetailsView: View {
    @StateObject var viewModel: BookingDetailsViewModel
    let pets: [Pet]

    var body: some View {
        Form {
            Section(NSLocalizedString("booking.pet", comment: "")) {
                Picker(NSLocalizedString("booking.pet.select", comment: ""), selection: $viewModel.selectedPet) {
                    ForEach(pets, id: \.id) { pet in
                        Text(pet.name).tag(Optional(pet))
                    }
                }
            }

            Section(NSLocalizedString("booking.address", comment: "")) {
                TextField(NSLocalizedString("booking.address.placeholder", comment: ""), text: $viewModel.address)
            }

            Section(NSLocalizedString("booking.duration", comment: "")) {
                Picker("", selection: $viewModel.duration) {
                    ForEach([30, 60, 90], id: \.self) { duration in
                        Text("\(duration) мин").tag(duration)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section(NSLocalizedString("booking.options", comment: "")) {
                ForEach(BookingOption.allCases) { option in
                    Button {
                        viewModel.toggle(option: option)
                    } label: {
                        HStack {
                            Text(option.title)
                            Spacer()
                            if viewModel.options.contains(option) { Image(systemName: "checkmark") }
                        }
                    }
                }
            }

            Section(NSLocalizedString("booking.price", comment: "")) {
                Text("₽\(Int(viewModel.price))")
                    .font(.title)
                    .bold()
                    .onAppear { viewModel.calculatePrice() }
            }
        }
        .navigationTitle(Text(NSLocalizedString("booking.details.title", comment: "")))
    }
}
