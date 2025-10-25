import Foundation

struct ValidationService {
    func validateEmail(_ email: String) -> Bool {
        let regex = try? NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
        return regex?.firstMatch(in: email, range: NSRange(location: 0, length: email.count)) != nil
    }

    func validatePhone(_ phone: String) -> Bool {
        phone.hasPrefix("+") && phone.count >= 10
    }

    func validateWeight(_ weight: Double) -> Bool {
        weight > 0
    }

    func validateFuture(date: Date) -> Bool {
        date > Date()
    }
}
