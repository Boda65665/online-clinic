import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    @EnvironmentObject private var environment: ApplicationEnvironment

    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("settings_profile".localized)) {
                    if case let .authenticated(user) = environment.sessionState {
                        Text(user.name)
                        Text(user.email ?? "")
                    }
                }

                Section(header: Text("settings_actions".localized)) {
                    Button("settings_cremation".localized) {
                        environment.services.coordinator.openCremationForm()
                    }
                    Button("settings_sign_out".localized) {
                        Task {
                            await viewModel.signOut()
                            environment.sessionState = .unauthenticated
                        }
                    }
                }
            }
            .overlay {
                if viewModel.isLoading { ProgressView() }
            }
            .navigationTitle("settings_title".localized)
        }
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel(authService: MockAuthService(), coordinator: CoordinatorBridge(), analytics: MockAnalyticsService()))
        .environmentObject(ApplicationEnvironment.preview)
}
