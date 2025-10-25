import Foundation

enum AnalyticsEvent {
    case appLaunched
    case authCompleted(role: UserRole)
    case signOut
    case onboardingStep(String)
    case searchApplied(filters: [String])
    case bookingCreated
    case paymentCompleted
    case reviewSubmitted(Int)
    case cremationCreated
    case error(message: String)

    var name: String {
        switch self {
        case .appLaunched: return "app_launched"
        case .authCompleted: return "auth_completed"
        case .signOut: return "sign_out"
        case .onboardingStep: return "onboarding_step"
        case .searchApplied: return "search_applied"
        case .bookingCreated: return "booking_created"
        case .paymentCompleted: return "payment_completed"
        case .reviewSubmitted: return "review_submitted"
        case .cremationCreated: return "cremation_created"
        case .error: return "error"
        }
    }

    var parameters: [String: Any] {
        switch self {
        case .authCompleted(let role):
            return ["role": role.rawValue]
        case .onboardingStep(let step):
            return ["step": step]
        case .searchApplied(let filters):
            return ["filters": filters]
        case .reviewSubmitted(let rating):
            return ["rating": rating]
        case .error(let message):
            return ["message": message]
        default:
            return [:]
        }
    }
}

final class MockAnalyticsService: AnalyticsService {
    func track(event: AnalyticsEvent) {
        #if DEBUG
        print("[Analytics] \(event.name) - \(event.parameters)")
        #endif
    }
}
