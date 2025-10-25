import SwiftUI
import SwiftData

final class SettingsViewModel: ObservableObject {
    @Published var currentUser: User
    @Published var selectedLanguage: String = Locale.preferredLanguages.first ?? "ru"
    @Published var notificationsEnabled = true

    init(currentUser: User) {
        self.currentUser = currentUser
    }

    func toggleRole() {
        currentUser.role = currentUser.role == .owner ? .walker : .owner
        try? ModelContext(AppModelContainer.shared.container).save()
    }
}

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var notificationsEnabled = true

    var body: some View {
        NavigationStack {
            Form {
                Section(NSLocalizedString("settings.profile", comment: "")) {
                    HStack {
                        Circle().fill(Color(.systemTeal)).frame(width: 56, height: 56)
                            .overlay(Text(String(viewModel.currentUser.name.prefix(1))).foregroundColor(.white).font(.title))
                        VStack(alignment: .leading) {
                            Text(viewModel.currentUser.name).font(.title3)
                            Text(viewModel.currentUser.email).font(.footnote).foregroundColor(.secondary)
                        }
                    }
                    Button(NSLocalizedString("settings.switchrole", comment: "")) {
                        viewModel.toggleRole()
                    }
                }

                Section(NSLocalizedString("settings.preferences", comment: "")) {
                    Toggle(NSLocalizedString("settings.notifications", comment: ""), isOn: $notificationsEnabled)
                    Picker(NSLocalizedString("settings.language", comment: ""), selection: $viewModel.selectedLanguage) {
                        Text("Русский").tag("ru")
                        Text("English").tag("en")
                    }
                }

                Section(NSLocalizedString("settings.about", comment: "")) {
                    NavigationLink(NSLocalizedString("settings.privacy", comment: "")) {
                        Text(String(localized: "privacy.text"))
                    }
                    NavigationLink(NSLocalizedString("settings.terms", comment: "")) {
                        Text(String(localized: "terms.text"))
                    }
                }

                Section {
                    Button(NSLocalizedString("settings.logout", comment: ""), role: .destructive) {
                        coordinator.signOut()
                    }
                }
            }
            .navigationTitle(Text(NSLocalizedString("settings.title", comment: "")))
        }
    }
}
