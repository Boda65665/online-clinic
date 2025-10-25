import Foundation
import Combine

final class OnboardingViewModel: ObservableObject {
    enum Step: Int { case role, permissions, summary }

    @Published var step: Step = .role
    @Published var selectedRole: UserRole = .owner
    @Published var notificationsGranted = false
    @Published var locationGranted = false

    private let authService: AuthService
    private let notificationService: NotificationService
    private let locationService: LocationService
    private let analytics: AnalyticsService
    private let completion: () -> Void

    init(authService: AuthService, notificationService: NotificationService, locationService: LocationService, analytics: AnalyticsService, completion: @escaping () -> Void) {
        self.authService = authService
        self.notificationService = notificationService
        self.locationService = locationService
        self.analytics = analytics
        self.completion = completion
    }

    func requestNotifications() async {
        do {
            try await notificationService.requestAuthorization()
            await MainActor.run { notificationsGranted = true }
        } catch {
            await MainActor.run { notificationsGranted = false }
        }
    }

    func requestLocation() async {
        await locationService.requestPermission()
        await MainActor.run { locationGranted = true }
    }

    func continueFlow() {
        switch step {
        case .role: step = .permissions
        case .permissions: step = .summary
        case .summary:
            Task {
                await analytics.track(event: .onboardingCompleted)
                completion()
            }
        }
    }
}
