import SwiftUI
import SwiftData
import Combine

@main
struct PawLinkApp: App {
    @State private var coordinator = AppCoordinator()
    @State private var appEnvironment = ApplicationEnvironment()

    var body: some Scene {
        WindowGroup {
            RootView()
                .onAppear {
                    if let bridge = appEnvironment.services.coordinator as? CoordinatorBridge {
                        bridge.attach(coordinator)
                    }
                }
                .environment(\.modelContext, appEnvironment.modelContext)
                .environmentObject(appEnvironment)
                .environmentObject(coordinator)
                .task {
                    await appEnvironment.bootstrap()
                }
        }
    }
}
