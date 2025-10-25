import SwiftUI
import Combine

final class WalksHomeViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var isLoading = false
    @Published var error: AppError?

    private let bookingService: BookingService
    private var cancellables = Set<AnyCancellable>()
    private let currentUser: User

    init(currentUser: User, bookingService: BookingService = MockBookingService()) {
        self.currentUser = currentUser
        self.bookingService = bookingService
        fetch()
    }

    func fetch() {
        isLoading = true
        bookingService.fetchBookings(for: currentUser)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] bookings in
                self?.bookings = bookings.sorted(by: { $0.start < $1.start })
            }
            .store(in: &cancellables)
    }
}

struct WalksHomeView: View {
    @StateObject private var viewModel: WalksHomeViewModel

    init(user: User) {
        _viewModel = StateObject(wrappedValue: WalksHomeViewModel(currentUser: user))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    VStack(spacing: 16) {
                        SkeletonView().frame(height: 120)
                        SkeletonView().frame(height: 120)
                    }
                } else if viewModel.bookings.isEmpty {
                    ContentUnavailableView(
                        NSLocalizedString("booking.empty", comment: ""),
                        systemImage: "pawprint.slash",
                        description: Text(NSLocalizedString("booking.empty.desc", comment: ""))
                    )
                } else {
                    List {
                        ForEach(viewModel.bookings, id: \.id) { booking in
                            BookingCard(booking: booking)
                                .listRowInsets(EdgeInsets())
                                .padding(.vertical, 8)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable { viewModel.fetch() }
                }
            }
            .navigationTitle(Text(NSLocalizedString("booking.title", comment: "")))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SlotPickerView(viewModel: SlotPickerViewModel(mode: .owner))) {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert(viewModel.error?.localizedDescription ?? "", isPresented: Binding(get: { viewModel.error != nil }, set: { if !$0 { viewModel.error = nil } })) {
                Button("OK", role: .cancel) { viewModel.error = nil }
            }
        }
    }
}

struct BookingCard: View {
    let booking: Booking

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(DateFormatter.localizedString(from: booking.start, dateStyle: .medium, timeStyle: .short))
                    .font(.title2)
                Spacer()
                Text(booking.status.timelineTitle)
                    .font(.footnote)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Capsule().fill(Color(.systemTeal).opacity(0.2)))
            }
            Text(booking.address)
                .font(.body)
            Text("₽\(Int(booking.price)) • \(booking.durationMin) мин")
                .font(.footnote)
                .foregroundStyle(Color.secondary)
        }
        .cardStyle()
    }
}
