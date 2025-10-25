import SwiftUI
import Combine

final class AppCoordinator: ObservableObject {
    @Published var presentedSheet: SheetRoute?
    private var cancellables = Set<AnyCancellable>()

    func handleLaunch() {
        // TODO: Integrate remote config / analytics for launch events.
    }

    func present(route: SheetRoute?) {
        withAnimation(.easeInOut(duration: 0.25)) {
            presentedSheet = route
        }
    }
}

enum SheetRoute: Identifiable {
    case booking(BookingFlowInput)
    case cremationCreate

    var id: String {
        switch self {
        case .booking(let input):
            return "booking_\(input.walker.id.uuidString)"
        case .cremationCreate:
            return "cremation_create"
        }
    }
}

struct BookingFlowInput {
    let walker: Walker
    let owner: User
}
