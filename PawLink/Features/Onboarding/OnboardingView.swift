import SwiftUI
import AuthenticationServices

struct OnboardingView: View {
    enum Step: Int, CaseIterable {
        case welcome, role, permissions, auth
    }

    @State private var step: Step = .welcome
    @State private var selectedRole: UserRole = .owner
    @State private var email: String = ""
    @State private var isLoading = false
    @State private var error: AppError?

    let completion: (AuthResult) -> Void
    private let authService: AuthService

    init(authService: AuthService = MockAuthService(), completion: @escaping (AuthResult) -> Void) {
        self.authService = authService
        self.completion = completion
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text(title)
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text(description)
                .font(.body)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            content
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal)

            Spacer()

            HStack {
                if step != .welcome {
                    Button(action: previous) {
                        Text(NSLocalizedString("onboarding.back", comment: ""))
                    }
                }
                Spacer()
                Button(action: next) {
                    Text(step == .auth ? NSLocalizedString("onboarding.finish", comment: "") : NSLocalizedString("onboarding.next", comment: ""))
                        .bold()
                }
                .disabled(step == .auth && email.isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .overlay {
            if isLoading {
                ProgressView().progressViewStyle(.circular)
            }
        }
        .alert(error?.localizedDescription ?? "", isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } })) {
            Button("OK", role: .cancel) { error = nil }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case .welcome:
            VStack(spacing: 16) {
                Text(NSLocalizedString("onboarding.welcome.message", comment: ""))
                    .font(.title2)
                    .multilineTextAlignment(.center)
            }
        case .role:
            VStack(spacing: 12) {
                ForEach(UserRole.allCases) { role in
                    Button {
                        selectedRole = role
                    } label: {
                        HStack {
                            Text(role.localizedTitle)
                                .font(.title2)
                            Spacer()
                            if selectedRole == role {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.accentColor)
                            }
                        }
                        .padding()
                    }
                    .pillStyle(isSelected: selectedRole == role)
                }
            }
        case .permissions:
            VStack(spacing: 16) {
                Label(NSLocalizedString("onboarding.permission.location", comment: ""), systemImage: "location")
                Label(NSLocalizedString("onboarding.permission.notifications", comment: ""), systemImage: "bell")
                Label(NSLocalizedString("onboarding.permission.health", comment: ""), systemImage: "pawprint")
            }
        case .auth:
            VStack(spacing: 20) {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        if case let credential as ASAuthorizationAppleIDCredential = authorization.credential {
                            isLoading = true
                            authService.signInWithApple(token: credential.user) { handleAuthResult($0) }
                        }
                    case .failure(let error):
                        self.error = .network(error.localizedDescription)
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 52)

                TextField(NSLocalizedString("auth.email", comment: ""), text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).fill(Color(.systemGray6)))

                Button(NSLocalizedString("auth.email.button", comment: "")) {
                    guard email.contains("@") else {
                        error = .validation(NSLocalizedString("auth.email.invalid", comment: ""))
                        return
                    }
                    isLoading = true
                    authService.signIn(email: email) { handleAuthResult($0) }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private func previous() {
        guard let newStep = Step(rawValue: step.rawValue - 1) else { return }
        step = newStep
    }

    private func next() {
        if step == .auth { return }
        guard let newStep = Step(rawValue: step.rawValue + 1) else { return }
        step = newStep
    }

    private var title: String {
        switch step {
        case .welcome: return NSLocalizedString("onboarding.title.welcome", comment: "")
        case .role: return NSLocalizedString("onboarding.title.role", comment: "")
        case .permissions: return NSLocalizedString("onboarding.title.permissions", comment: "")
        case .auth: return NSLocalizedString("onboarding.title.auth", comment: "")
        }
    }

    private var description: String {
        switch step {
        case .welcome: return NSLocalizedString("onboarding.desc.welcome", comment: "")
        case .role: return NSLocalizedString("onboarding.desc.role", comment: "")
        case .permissions: return NSLocalizedString("onboarding.desc.permissions", comment: "")
        case .auth: return NSLocalizedString("onboarding.desc.auth", comment: "")
        }
    }

    private func handleAuthResult(_ result: Result<User, AppError>) {
        DispatchQueue.main.async {
            isLoading = false
            switch result {
            case .success(let user):
                user.role = selectedRole
                completion(.success(user))
            case .failure(let error):
                self.error = error
                completion(.failure(error))
            }
        }
    }
}

enum AuthResult {
    case success(User)
    case failure(AppError)
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView { _ in }
    }
}
