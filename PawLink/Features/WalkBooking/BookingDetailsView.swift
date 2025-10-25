import SwiftUI

struct BookingDetailsView: View {
    @StateObject var viewModel: BookingDetailsViewModel
    var onConfirm: (Booking) -> Void

    @State private var showError: AppError?

    init(viewModel: BookingDetailsViewModel, onConfirm: @escaping (Booking) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onConfirm = onConfirm
    }

    var body: some View {
        Form {
            Section(header: Text("booking_pet".localized)) {
                Picker("booking_pet".localized, selection: $viewModel.selectedPetId) {
                    Text("booking_pet_placeholder".localized).tag(UUID?.none)
                    ForEach(viewModel.pets) { pet in
                        Text(pet.name).tag(UUID?.some(pet.id))
                    }
                }
            }

            Section(header: Text("booking_address".localized)) {
                TextField("booking_address_placeholder".localized, text: $viewModel.address)
            }

            Section(header: Text("booking_duration".localized)) {
                Picker("booking_duration".localized, selection: $viewModel.duration) {
                    ForEach([30, 60, 90], id: \.self) { duration in
                        Text("\(duration) мин").tag(duration)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section(header: Text("booking_options".localized)) {
                ForEach(BookingOption.allCases) { option in
                    Toggle(isOn: Binding(
                        get: { viewModel.options.contains(option) },
                        set: { isOn in
                            if isOn { viewModel.options.insert(option) } else { viewModel.options.remove(option) }
                        }
                    )) {
                        Text(option.localizedTitle)
                    }
                }
            }
        }
        .navigationTitle("booking_details_title".localized)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("next".localized) {
                    Task {
                        do {
                            let booking = try await viewModel.confirmBooking()
                            onConfirm(booking)
                        } catch {
                            showError = AppError(error)
                        }
                    }
                }
            }
        }
        .alert(item: $showError) { error in
            Alert(title: Text(error.title), message: Text(error.message), dismissButton: .default(Text("ok".localized)))
        }
    }
}

#Preview {
    BookingDetailsView(viewModel: BookingDetailsViewModel(owner: MockData.previewOwner, walker: MockData.walkers().first!, slot: MockData.walkers().first!.availability.first!, bookingService: MockBookingService(), notificationService: MockNotificationService(), analytics: MockAnalyticsService()), onConfirm: { _ in })
}
