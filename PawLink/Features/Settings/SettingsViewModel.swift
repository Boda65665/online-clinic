import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isLoading = false
    private let authService: AuthService
    private let coordinator: AppCoordinatorService
    private let analytics: AnalyticsService

    init(authService: AuthService, coordinator: AppCoordinatorService, analytics: AnalyticsService) {
        self.authService = authService
        self.coordinator = coordinator
        self.analytics = analytics
    }

    func signOut() async {
        isLoading = true
        defer { isLoading = false }
        try? await authService.signOut()
    }
}
