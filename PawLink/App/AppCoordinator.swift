import SwiftUI
import Combine
import SwiftData
import MapKit

final class AppCoordinator: ObservableObject {
    enum AppState {
        case onboarding
        case authenticated(User)
    }

    @Published private(set) var state: AppState = .onboarding
    @Published var tabSelection: MainTab = .walks
    private var cancellables = Set<AnyCancellable>()

    let authService: AuthService
    private let notificationService: NotificationService
    private let analytics: AnalyticsService
    private let locationService: LocationService

    init(authService: AuthService = MockAuthService(),
         notificationService: NotificationService = MockNotificationService(),
         analytics: AnalyticsService = MockAnalyticsService(),
         locationService: LocationService = MockLocationService()) {
        self.authService = authService
        self.notificationService = notificationService
        self.analytics = analytics
        self.locationService = locationService

        authService.userPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                if let user {
                    self?.state = .authenticated(user)
                } else {
                    self?.state = .onboarding
                }
            }
            .store(in: &cancellables)
    }

    @MainActor
    func bootstrap() async {
        await notificationService.requestAuthorization()
        locationService.requestAuthorization()
        analytics.track(event: .appLaunched)
        if let user = authService.currentUser {
            state = .authenticated(user)
        }
    }

    func handleSignIn(result: AuthResult) {
        switch result {
        case .success(let user):
            analytics.track(event: .authCompleted(role: user.role))
            state = .authenticated(user)
        case .failure(let error):
            analytics.track(event: .error(message: error.localizedDescription))
        }
    }

    func signOut() {
        authService.signOut()
        state = .onboarding
        analytics.track(event: .signOut)
    }
}

enum MainTab: Hashable {
    case walks
    case map
    case cremation
    case chat
    case profile
}

struct RootView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        Group {
            switch coordinator.state {
            case .onboarding:
                OnboardingFlow()
            case .authenticated(let user):
                MainTabView(user: user)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task { await coordinator.bootstrap() }
        }
    }
}

struct OnboardingFlow: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        OnboardingView(authService: coordinator.authService) { result in
            coordinator.handleSignIn(result: result)
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    let user: User

    var body: some View {
        TabView(selection: $coordinator.tabSelection) {
            WalksHomeView(user: user)
                .tabItem { Label("Прогулки", systemImage: "pawprint") }
                .tag(MainTab.walks)

            MapSearchView(user: user)
                .tabItem { Label("Карта", systemImage: "map") }
                .tag(MainTab.map)

            CremationListView(viewModel: CremationListViewModel(user: user))
                .tabItem { Label("Кремация", systemImage: "flame") }
                .tag(MainTab.cremation)

            ChatListView(viewModel: ChatListViewModel(currentUser: user))
                .tabItem { Label("Чат", systemImage: "bubble.left.and.bubble.right") }
                .tag(MainTab.chat)

            SettingsView(viewModel: SettingsViewModel(currentUser: user))
                .tabItem { Label("Профиль", systemImage: "person.crop.circle") }
                .tag(MainTab.profile)
        }
        .accentColor(.accentColor)
    }
}
