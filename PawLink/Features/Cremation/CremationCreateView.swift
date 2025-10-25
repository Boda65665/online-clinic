import SwiftUI

struct CremationCreateView: View {
    @StateObject var viewModel: CremationCreateViewModel
    let owner: User
    var onCreated: (CremationOrder) -> Void

    init(viewModel: CremationCreateViewModel, owner: User, onCreated: @escaping (CremationOrder) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.owner = owner
        self.onCreated = onCreated
    }

    var body: some View {
        Form {
            Section(header: Text("cremation_pet".localized)) {
                Picker("cremation_pet".localized, selection: $viewModel.selectedPetId) {
                    Text("cremation_pet_new".localized).tag(UUID?.none)
                    ForEach(MockData.pets(owner: owner)) { pet in
                        Text(pet.name).tag(UUID?.some(pet.id))
                    }
                }
            }
            Section(header: Text("cremation_weight".localized)) {
                TextField("cremation_weight_placeholder".localized, text: $viewModel.weightText)
                    .keyboardType(.decimalPad)
            }
            Section(header: Text("cremation_address".localized)) {
                TextField("cremation_address_placeholder".localized, text: $viewModel.address)
            }
            Section(header: Text("cremation_contact".localized)) {
                TextField("cremation_contact_name".localized, text: $viewModel.contactName)
                TextField("cremation_contact_phone".localized, text: $viewModel.contactPhone)
                    .keyboardType(.phonePad)
                TextField("cremation_contact_email".localized, text: $viewModel.contactEmail)
                    .keyboardType(.emailAddress)
            }
            Section(header: Text("cremation_package".localized)) {
                Picker("", selection: $viewModel.package) {
                    ForEach(CremationPackage.allCases) { pkg in
                        Text(pkg.localizedTitle).tag(pkg)
                    }
                }
                .pickerStyle(.segmented)
            }
            Section(header: Text("cremation_wishes".localized)) {
                TextField("cremation_wishes_placeholder".localized, text: $viewModel.wishes, axis: .vertical)
            }
            Section(header: Text("cremation_pickup".localized)) {
                DatePicker("", selection: $viewModel.pickupAt, in: Date()..., displayedComponents: [.date, .hourAndMinute])
            }
            Section {
                Toggle(isOn: $viewModel.consentAccepted) {
                    Text("cremation_consent".localized)
                }
            }
        }
        .navigationTitle("cremation_create_title".localized)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("create".localized) {
                    Task {
                        if let order = await viewModel.submit(owner: owner) {
                            onCreated(order)
                        }
                    }
                }
                .disabled(viewModel.isLoading)
            }
        }
        .overlay {
            if viewModel.isLoading { ProgressView() }
        }
        .alert(item: $viewModel.error) { error in
            Alert(title: Text(error.title), message: Text(error.message), dismissButton: .default(Text("ok".localized)))
        }
    }
}

#Preview {
    CremationCreateView(viewModel: ApplicationEnvironment.preview.makeCremationCreateViewModel(), owner: MockData.previewOwner, onCreated: { _ in })
}
