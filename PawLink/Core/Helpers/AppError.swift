import Foundation

enum AppError: LocalizedError, Identifiable {
    var id: String { localizedDescription }

    case network(String)
    case validation(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .network(let message):
            return message
        case .validation(let message):
            return message
        case .unknown:
            return NSLocalizedString("error.unknown", comment: "")
        }
    }
}
