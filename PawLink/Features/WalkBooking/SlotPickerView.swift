import SwiftUI

struct SlotPickerView: View {
    @ObservedObject var viewModel: SlotPickerViewModel
    var onSelect: (TimeSlot) -> Void

    var body: some View {
        List {
            Section(header: Text("slot_picker_title".localized)) {
                ForEach(viewModel.slots) { slot in
                    Button {
                        onSelect(slot)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(slot.start, style: .date)
                                Text("\(slot.start, style: .time) - \(slot.end, style: .time)")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if slot.isBooked {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .disabled(slot.isBooked)
                }
            }
        }
        .navigationTitle("slot_picker_nav".localized)
    }
}

#Preview {
    SlotPickerView(viewModel: SlotPickerViewModel(walker: MockData.walkers().first!, bookingService: MockBookingService(), analytics: MockAnalyticsService()), onSelect: { _ in })
}
