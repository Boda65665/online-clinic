import SwiftUI

struct BookingStatusViewModel {
    let booking: Booking

    var timeline: [BookingStatus] {
        BookingStatus.allCases
    }
}

struct BookingStatusView: View {
    let viewModel: BookingStatusViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                let currentIndex = viewModel.timeline.firstIndex(of: viewModel.booking.status) ?? 0
                ForEach(Array(viewModel.timeline.enumerated()), id: \.element.id) { index, status in
                    HStack(alignment: .top, spacing: 16) {
                        Circle()
                            .fill(index <= currentIndex ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 16, height: 16)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(status.timelineTitle)
                                .font(.title3)
                            if status == viewModel.booking.status {
                                Text(DateFormatter.localizedString(from: viewModel.booking.start, dateStyle: .medium, timeStyle: .short))
                                    .font(.footnote)
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                    }
                    Divider()
                }
                ShareLink(item: viewModel.booking.address) {
                    Label(NSLocalizedString("booking.share", comment: ""), systemImage: "square.and.arrow.up")
                }
            }
            .padding()
        }
        .navigationTitle(Text(NSLocalizedString("booking.status.title", comment: "")))
    }
}
