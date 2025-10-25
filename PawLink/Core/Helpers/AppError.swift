import Foundation

struct AppError: Identifiable, Error {
    let id = UUID()
    let title: String
    let message: String

    init(title: String, message: String) {
        self.title = title
        self.message = message
    }

    init(_ error: Error) {
        if let appError = error as? AppError {
            self = appError
        } else {
            self.title = "error_generic_title".localized
            self.message = error.localizedDescription
        }
    }
}
