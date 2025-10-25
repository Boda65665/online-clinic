import Foundation
import AuthenticationServices

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var isLoading = false
    @Published var error: AppError?
    @Published var signedInUser: User?

    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    func signInWithApple() async {
        isLoading = true
        defer { isLoading = false }
        do {
            signedInUser = try await authService.signInWithApple()
        } catch {
            self.error = AppError(error)
        }
    }

    func signInWithEmail() async {
        guard !email.isEmpty else {
            error = AppError(title: "auth_error".localized, message: "email_empty".localized)
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            signedInUser = try await authService.signIn(email: email)
        } catch {
            error = AppError(error)
        }
    }
}
