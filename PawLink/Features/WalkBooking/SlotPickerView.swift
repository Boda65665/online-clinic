import SwiftUI
import Combine

final class SlotPickerViewModel: ObservableObject {
    enum Mode { case owner, walker }

    @Published var walkers: [Walker] = []
    @Published var selectedWalker: Walker?
    @Published var selectedSlot: TimeSlot?
    @Published var isLoading = false
    @Published var error: AppError?

    private let mode: Mode
    private let walkerService: WalkerService
    private var cancellables = Set<AnyCancellable>()

    init(mode: Mode = .owner, walkerService: WalkerService = MockWalkerService()) {
        self.mode = mode
        self.walkerService = walkerService
        fetch()
    }

    func fetch() {
        isLoading = true
        walkerService.fetchWalkers()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] walkers in
                self?.walkers = walkers
            }
            .store(in: &cancellables)
    }
}

struct SlotPickerView: View {
    @StateObject var viewModel: SlotPickerViewModel

    var body: some View {
        List {
            Section(NSLocalizedString("slot.walkers", comment: "")) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.walkers, id: \.id) { walker in
                            Button {
                                viewModel.selectedWalker = walker
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(walker.userId.uuidString.prefix(6))
                                        .font(.title2)
                                    Text("₽\(Int(walker.ratePerHour))/ч")
                                        .font(.footnote)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).fill(viewModel.selectedWalker?.id == walker.id ? AppTheme.accent.opacity(0.2) : Color(.systemGray6)))
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }

            if let walker = viewModel.selectedWalker {
                Section(NSLocalizedString("slot.available", comment: "")) {
                    ForEach(walker.availability.filter { !$0.isBooked }, id: \.id) { slot in
                        Button {
                            viewModel.selectedSlot = slot
                        } label: {
                            HStack {
                                Text(DateFormatter.localizedString(from: slot.start, dateStyle: .medium, timeStyle: .short))
                                Spacer()
                                if viewModel.selectedSlot?.id == slot.id {
                                    Image(systemName: "checkmark.circle.fill").foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                }
            }
        }
        .overlay {
            if viewModel.isLoading { ProgressView() }
        }
        .alert(viewModel.error?.localizedDescription ?? "", isPresented: Binding(get: { viewModel.error != nil }, set: { if !$0 { viewModel.error = nil } })) {
            Button("OK", role: .cancel) { viewModel.error = nil }
        }
        .navigationTitle(Text(NSLocalizedString("slot.title", comment: "")))
    }
}
