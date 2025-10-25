import SwiftUI
import Combine
import SwiftData
import CoreLocation

final class ApplicationEnvironment: ObservableObject {
    enum SessionState {
        case loading
        case unauthenticated
        case authenticated(User)
    }

    @Published var sessionState: SessionState = .loading
    @Published var selectedTab: MainTab = .walks
    @Published var activeError: AppError?
    @Published var hasCompletedOnboarding = false

    let services: ServiceRegistry
    let modelContainer: ModelContainer
    var modelContext: ModelContext { modelContainer.mainContext }

    private lazy var homeViewModelInstance = HomeOwnerViewModel(walkerService: services.walkers, bookingService: services.bookings, analytics: services.analytics, coordinator: services.coordinator)
    private lazy var mapViewModelInstance = MapSearchViewModel(walkerService: services.walkers, locationService: services.location, analytics: services.analytics)
    private lazy var cremationListViewModelInstance = CremationListViewModel(service: services.cremation, analytics: services.analytics, notificationService: services.notifications)
    private lazy var chatListViewModelInstance = ChatListViewModel(chatService: services.chat, analytics: services.analytics)
    private lazy var settingsViewModelInstance = SettingsViewModel(authService: services.auth, coordinator: services.coordinator, analytics: services.analytics)
    init(services: ServiceRegistry = .init(), container: ModelContainer = PersistenceController.shared.container) {
        self.services = services
        self.modelContainer = container
    }

    func bootstrap() async {
        await services.analytics.track(event: .appLaunched)
        do {
            try await services.bootstrap()
            try await services.auth.restoreSession()
            await MainActor.run {
                if let user = services.auth.currentUser {
                    sessionState = .authenticated(user)
                    hasCompletedOnboarding = true
                } else {
                    sessionState = .unauthenticated
                }
            }
        } catch {
            await MainActor.run {
                activeError = AppError(error)
                sessionState = .unauthenticated
            }
        }
    }

    func makeOnboardingViewModel() -> OnboardingViewModel {
        OnboardingViewModel(authService: services.auth, notificationService: services.notifications, locationService: services.location, analytics: services.analytics) { [weak self] in
            self?.hasCompletedOnboarding = true
        }
    }

    func makeHomeViewModel() -> HomeOwnerViewModel {
        homeViewModelInstance
    }

    func makeMapSearchViewModel() -> MapSearchViewModel {
        mapViewModelInstance
    }

    func makeCremationListViewModel() -> CremationListViewModel {
        cremationListViewModelInstance
    }

    func makeCremationCreateViewModel() -> CremationCreateViewModel {
        CremationCreateViewModel(service: services.cremation, analytics: services.analytics, notificationService: services.notifications, validation: ValidationService())
    }

    func makeChatListViewModel() -> ChatListViewModel {
        chatListViewModelInstance
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        settingsViewModelInstance
    }

    func makeBookingFlowCoordinator(input: BookingFlowInput) -> BookingFlowCoordinator {
        BookingFlowCoordinator(input: input, services: services)
    }

    static var preview: ApplicationEnvironment {
        let environment = ApplicationEnvironment()
        environment.sessionState = .authenticated(MockData.previewOwner)
        environment.hasCompletedOnboarding = true
        return environment
    }
}

enum MainTab: Hashable {
    case walks
    case map
    case cremation
    case chat
    case profile
}

struct ServiceRegistry {
    let auth: AuthService
    let walkers: WalkerService
    let bookings: BookingService
    let chat: ChatService
    let cremation: CremationService
    let payment: PaymentService
    let notifications: NotificationService
    let analytics: AnalyticsService
    let location: LocationService
    let coordinator: AppCoordinatorService

    init(auth: AuthService = MockAuthService(),
         walkers: WalkerService = MockWalkerService(),
         bookings: BookingService = MockBookingService(),
         chat: ChatService = MockChatService(),
         cremation: CremationService = MockCremationService(),
         payment: PaymentService = MockPaymentService(),
         notifications: NotificationService = MockNotificationService(),
         analytics: AnalyticsService = MockAnalyticsService(),
         location: LocationService = MockLocationService(),
         coordinator: AppCoordinatorService = CoordinatorBridge()) {
        self.auth = auth
        self.walkers = walkers
        self.bookings = bookings
        self.chat = chat
        self.cremation = cremation
        self.payment = payment
        self.notifications = notifications
        self.analytics = analytics
        self.location = location
        self.coordinator = coordinator
    }

    func bootstrap() async throws {
        if let mockBootstrapper = auth as? MockAuthService {
            try await mockBootstrapper.prepareInitialData()
        }
        if let walkerMock = walkers as? MockWalkerService {
            try await walkerMock.prepareInitialData()
        }
        if let bookingMock = bookings as? MockBookingService {
            try await bookingMock.prepareInitialData()
        }
        if let cremationMock = cremation as? MockCremationService {
            try await cremationMock.prepareInitialData()
        }
        if let chatMock = chat as? MockChatService {
            try await chatMock.prepareInitialData()
        }
    }
}

protocol AppCoordinatorService {
    func openBooking(for walker: Walker, owner: User)
    func openCremationForm()
}

final class CoordinatorBridge: AppCoordinatorService {
    private weak var coordinator: AppCoordinator?

    init(coordinator: AppCoordinator? = nil) {
        self.coordinator = coordinator
    }

    func attach(_ coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }

    func openBooking(for walker: Walker, owner: User) {
        coordinator?.present(route: .booking(.init(walker: walker, owner: owner)))
    }

    func openCremationForm() {
        coordinator?.present(route: .cremationCreate)
    }
}
