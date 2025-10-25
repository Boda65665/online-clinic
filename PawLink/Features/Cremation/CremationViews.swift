import SwiftUI
import Combine
import SwiftData
import PDFKit

final class CremationListViewModel: ObservableObject {
    @Published var orders: [CremationOrder] = []
    @Published var selectedStatus: CremationStatus? = nil
    @Published var selectedDate = Date()
    @Published var isLoading = false
    @Published var error: AppError?

    let user: User
    private let service: CremationService
    private let notificationService: NotificationService
    private var cancellables = Set<AnyCancellable>()

    init(user: User,
         service: CremationService = MockCremationService(),
         notificationService: NotificationService = MockNotificationService()) {
        self.user = user
        self.service = service
        self.notificationService = notificationService
        fetch()
    }

    func fetch() {
        isLoading = true
        service.fetchOrders(ownerId: user.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] orders in
                self?.orders = orders
                if let date = orders.sorted(by: { $0.pickupAt < $1.pickupAt }).first?.pickupAt {
                    self?.selectedDate = date
                }
            }
            .store(in: &cancellables)
    }

    var filteredOrders: [CremationOrder] {
        orders.filter { order in
            let sameDay = Calendar.current.isDate(order.pickupAt, inSameDayAs: selectedDate)
            let matchesStatus = selectedStatus == nil || order.status == selectedStatus
            return sameDay && matchesStatus
        }
    }

    func scheduleNotifications(for order: CremationOrder) {
        notificationService.scheduleReminder(for: order)
    }
}

final class CremationCreateViewModel: ObservableObject {
    @Published var selectedPet: Pet?
    @Published var weight: String = ""
    @Published var address: String = ""
    @Published var contactName: String = ""
    @Published var phone: String = ""
    @Published var email: String = ""
    @Published var wishes: String = ""
    @Published var pickupAt: Date = Date().addingTimeInterval(86400)
    @Published var package: CremationPackage = .standard
    @Published var consent = false
    @Published var error: AppError?

    private let owner: User
    private let service: CremationService
    private let notificationService: NotificationService
    private var cancellables = Set<AnyCancellable>()

    init(owner: User,
         service: CremationService = MockCremationService(),
         notificationService: NotificationService = MockNotificationService()) {
        self.owner = owner
        self.service = service
        self.notificationService = notificationService
    }

    func create(pet: Pet?) {
        guard let weightValue = Double(weight), weightValue > 0 else {
            error = .validation(NSLocalizedString("cremation.weight.invalid", comment: ""))
            return
        }
        guard !contactName.trimmingCharacters(in: .whitespaces).isEmpty else {
            error = .validation(NSLocalizedString("cremation.contact.name", comment: ""))
            return
        }
        guard phone.starts(with: "+") else {
            error = .validation(NSLocalizedString("cremation.phone.invalid", comment: ""))
            return
        }
        guard email.contains("@") else {
            error = .validation(NSLocalizedString("cremation.email.invalid", comment: ""))
            return
        }
        guard consent else {
            error = .validation(NSLocalizedString("cremation.consent", comment: ""))
            return
        }

        let order = CremationOrder(ownerId: owner.id,
                                   petId: pet?.id ?? UUID(),
                                   weightKg: weightValue,
                                   pickupAddress: address,
                                   contactName: contactName,
                                   contactPhone: phone,
                                   contactEmail: email,
                                   packageType: package,
                                   wishes: wishes.isEmpty ? nil : wishes,
                                   pickupAt: pickupAt,
                                   status: .created)
        service.create(order: order)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] newOrder in
                self?.notificationService.scheduleReminder(for: newOrder)
            }
            .store(in: &cancellables)
    }
}

final class CremationDetailViewModel: ObservableObject {
    @Published var order: CremationOrder
    @Published var pdfURL: URL?

    private let pdfGenerator = CremationPDFGenerator()
    private let service: CremationService
    private var cancellables = Set<AnyCancellable>()

    init(order: CremationOrder, service: CremationService = MockCremationService()) {
        self.order = order
        self.service = service
    }

    func generatePDF() {
        pdfURL = pdfGenerator.generate(order: order)
    }

    func updateStatus(_ status: CremationStatus) {
        order.status = status
        service.update(order: order)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}

struct CremationListView: View {
    @StateObject var viewModel: CremationListViewModel
    @State private var showCreate = false

    init(viewModel: CremationListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(NSLocalizedString("cremation.filter.date", comment: ""), selection: $viewModel.selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Button(NSLocalizedString("cremation.filter.all", comment: "")) {
                            viewModel.selectedStatus = nil
                        }
                        .pillStyle(isSelected: viewModel.selectedStatus == nil)

                        ForEach(CremationStatus.allCases) { status in
                            Button(status.timelineTitle) {
                                viewModel.selectedStatus = status
                            }
                            .pillStyle(isSelected: viewModel.selectedStatus == status)
                        }
                    }
                    .padding(.horizontal)
                }

                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if viewModel.filteredOrders.isEmpty {
                    ContentUnavailableView(NSLocalizedString("cremation.empty", comment: ""), systemImage: "flame", description: Text(NSLocalizedString("cremation.empty.desc", comment: "")))
                } else {
                    List(viewModel.filteredOrders, id: \.id) { order in
                        NavigationLink(destination: CremationDetailView(viewModel: CremationDetailViewModel(order: order))) {
                            CremationCard(order: order)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(Text(NSLocalizedString("cremation.title", comment: "")))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreate.toggle() }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreate) {
                CremationCreateView(viewModel: CremationCreateViewModel(owner: viewModel.user))
            }
        }
    }
}

struct CremationCard: View {
    let order: CremationOrder

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(order.status.timelineTitle)
                .font(.title3)
            Text(order.pickupAddress)
            Text(DateFormatter.localizedString(from: order.pickupAt, dateStyle: .medium, timeStyle: .short))
                .font(.footnote)
                .foregroundStyle(Color.secondary)
        }
        .cardStyle()
    }
}

struct CremationCreateView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: CremationCreateViewModel
    private let context = ModelContext(AppModelContainer.shared.container)

    var body: some View {
        NavigationStack {
            Form {
                Section(NSLocalizedString("cremation.pet", comment: "")) {
                    Picker(NSLocalizedString("cremation.pet.select", comment: ""), selection: $viewModel.selectedPet) {
                        ForEach(fetchPets(), id: \.id) { pet in
                            Text(pet.name).tag(Optional(pet))
                        }
                    }
                }
                Section(NSLocalizedString("cremation.details", comment: "")) {
                    TextField(NSLocalizedString("cremation.weight", comment: ""), text: $viewModel.weight)
                        .keyboardType(.decimalPad)
                    TextField(NSLocalizedString("cremation.address", comment: ""), text: $viewModel.address)
                    DatePicker(NSLocalizedString("cremation.pickup", comment: ""), selection: $viewModel.pickupAt, in: Date()...)
                    Picker(NSLocalizedString("cremation.package", comment: ""), selection: $viewModel.package) {
                        ForEach(CremationPackage.allCases) { pkg in
                            Text(pkg.localizedTitle).tag(pkg)
                        }
                    }
                }
                Section(NSLocalizedString("cremation.contact", comment: "")) {
                    TextField(NSLocalizedString("cremation.contact.name", comment: ""), text: $viewModel.contactName)
                    TextField(NSLocalizedString("cremation.contact.phone", comment: ""), text: $viewModel.phone)
                    TextField(NSLocalizedString("cremation.contact.email", comment: ""), text: $viewModel.email)
                        .keyboardType(.emailAddress)
                }
                Section(NSLocalizedString("cremation.wishes", comment: "")) {
                    TextEditor(text: $viewModel.wishes)
                        .frame(height: 120)
                }
                Toggle(NSLocalizedString("cremation.consent.label", comment: ""), isOn: $viewModel.consent)
            }
            .navigationTitle(Text(NSLocalizedString("cremation.create", comment: "")))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("cremation.save", comment: "")) {
                        viewModel.create(pet: viewModel.selectedPet)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.cancel", comment: "")) { dismiss() }
                }
            }
            .alert(viewModel.error?.localizedDescription ?? "", isPresented: Binding(get: { viewModel.error != nil }, set: { if !$0 { viewModel.error = nil } })) {
                Button("OK", role: .cancel) { viewModel.error = nil }
            }
        }
    }

    private func fetchPets() -> [Pet] {
        let descriptor = FetchDescriptor<Pet>()
        return (try? context.fetch(descriptor)) ?? []
    }
}

struct CremationDetailView: View {
    @ObservedObject var viewModel: CremationDetailViewModel

    var body: some View {
        List {
            Section(NSLocalizedString("cremation.timeline", comment: "")) {
                ForEach(CremationStatus.allCases, id: \.id) { status in
                    HStack {
                        Text(status.timelineTitle)
                        Spacer()
                        if status == viewModel.order.status {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                        }
                    }
                }
            }
            Section(NSLocalizedString("cremation.actions", comment: "")) {
                Button(NSLocalizedString("cremation.pdf", comment: "")) {
                    viewModel.generatePDF()
                }
                if let url = viewModel.pdfURL {
                    ShareLink(item: url) {
                        Label(NSLocalizedString("cremation.share", comment: ""), systemImage: "square.and.arrow.up")
                    }
                }
                Button(NSLocalizedString("cremation.status.advance", comment: "")) {
                    if let next = CremationStatus.allCases.first(where: { $0.rawValue > viewModel.order.status.rawValue }) {
                        viewModel.updateStatus(next)
                    }
                }
            }
        }
        .navigationTitle(Text(NSLocalizedString("cremation.detail", comment: "")))
    }
}
