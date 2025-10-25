import Foundation
import SwiftData
import Combine

final class MockAuthService: AuthService {
    private let subject = CurrentValueSubject<User?, Never>(nil)
    var currentUser: User? {
        subject.value
    }

    var userPublisher: AnyPublisher<User?, Never> {
        subject.eraseToAnyPublisher()
    }

    init() {
        // Attempt to fetch any existing user for demo
        let context = ModelContext(AppModelContainer.shared.container)
        let descriptor = FetchDescriptor<User>()
        if let user = try? context.fetch(descriptor).first {
            subject.send(user)
        }
    }

    func signIn(email: String?, completion: @escaping (Result<User, AppError>) -> Void) {
        let context = ModelContext(AppModelContainer.shared.container)
        let descriptor = FetchDescriptor<User>()
        if let users = try? context.fetch(descriptor), let match = users.first(where: { $0.email.lowercased() == (email ?? "").lowercased() }) {
            subject.send(match)
            completion(.success(match))
        } else {
            completion(.failure(.validation(NSLocalizedString("auth.error", comment: ""))))
        }
    }

    func signInWithApple(token: String, completion: @escaping (Result<User, AppError>) -> Void) {
        // TODO: Integrate real Sign in with Apple backend validation
        let context = ModelContext(AppModelContainer.shared.container)
        let descriptor = FetchDescriptor<User>()
        if let user = try? context.fetch(descriptor).first {
            subject.send(user)
            completion(.success(user))
        } else {
            completion(.failure(.unknown))
        }
    }

    func signOut() {
        subject.send(nil)
    }
}
