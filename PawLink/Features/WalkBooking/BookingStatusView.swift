import SwiftUI

struct BookingStatusView: View {
    @ObservedObject var viewModel: BookingStatusViewModel

    var body: some View {
        List {
            ForEach(viewModel.timeline, id: \.self) { status in
                HStack {
                    Image(systemName: icon(for: status))
                        .foregroundStyle(color(for: status))
                    Text(status.rawValue.capitalized)
                    Spacer()
                    if status == viewModel.booking.status {
                        Text("status_current".localized)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("booking_status_title".localized)
    }

    private func icon(for status: BookingStatus) -> String {
        switch status {
        case .pending: return "hourglass"
        case .accepted: return "checkmark.circle"
        case .declined: return "xmark.circle"
        case .active: return "figure.walk"
        case .completed: return "flag.checkered"
        case .paid: return "creditcard"
        case .cancelled: return "xmark.octagon"
        }
    }

    private func color(for status: BookingStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .accepted: return .green
        case .declined, .cancelled: return .red
        case .active: return .blue
        case .completed: return .purple
        case .paid: return .teal
        }
    }
}

#Preview {
    BookingStatusView(viewModel: BookingStatusViewModel(booking: MockData.bookings(owner: MockData.previewOwner, walker: MockData.walkers().first!, pet: MockData.pets(owner: MockData.previewOwner).first!).first!))
}
