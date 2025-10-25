import SwiftUI

struct RootView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var environment: ApplicationEnvironment

    var body: some View {
        Group {
            if !environment.hasCompletedOnboarding {
                OnboardingFlow()
            } else if environment.sessionState == .unauthenticated {
                AuthView(viewModel: AuthViewModel(authService: environment.services.auth))
            } else {
                MainTabView()
            }
        }
        .onAppear {
            coordinator.handleLaunch()
        }
        .alert(item: $environment.activeError) { appError in
            Alert(title: Text(appError.title), message: Text(appError.message), dismissButton: .default(Text("ok".localized)))
        }
        .sheet(item: $coordinator.presentedSheet) { route in
            switch route {
            case .booking(let input):
                BookingFlowContainer(coordinator: environment.makeBookingFlowCoordinator(input: input))
            case .cremationCreate:
                if case let .authenticated(user) = environment.sessionState {
                    NavigationStack {
                        CremationCreateView(viewModel: environment.makeCremationCreateViewModel(), owner: user) { _ in
                            coordinator.present(route: nil)
                        }
                    }
                } else {
                    EmptyView()
                }
            }
        }
    }
}

struct OnboardingFlow: View {
    @EnvironmentObject private var environment: ApplicationEnvironment

    var body: some View {
        NavigationStack {
            OnboardingView(viewModel: environment.makeOnboardingViewModel())
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var environment: ApplicationEnvironment

    var body: some View {
        TabView(selection: $environment.selectedTab) {
            HomeOwnerView(viewModel: environment.makeHomeViewModel())
                .tabItem { Label("walks_tab_title".localized, systemImage: "figure.walk") }
                .tag(MainTab.walks)

            MapSearchView(viewModel: environment.makeMapSearchViewModel())
                .tabItem { Label("map_tab_title".localized, systemImage: "map") }
                .tag(MainTab.map)

            CremationListView(viewModel: environment.makeCremationListViewModel())
                .tabItem { Label("cremation_tab_title".localized, systemImage: "flame") }
                .tag(MainTab.cremation)

            ChatListView(viewModel: environment.makeChatListViewModel())
                .tabItem { Label("chat_tab_title".localized, systemImage: "bubble.left.and.bubble.right") }
                .tag(MainTab.chat)

            SettingsView(viewModel: environment.makeSettingsViewModel())
                .tabItem { Label("profile_tab_title".localized, systemImage: "person.crop.circle") }
                .tag(MainTab.profile)
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppCoordinator())
        .environmentObject(ApplicationEnvironment.preview)
}
