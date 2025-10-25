import SwiftUI
import Combine

struct AuthView: View {
    @StateObject var viewModel: AuthViewModel
    @EnvironmentObject private var environment: ApplicationEnvironment

    init(viewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 32) {
            Text("auth_title".localized)
                .font(.largeTitle)
                .bold()
            Button {
                Task { await viewModel.signInWithApple() }
            } label: {
                Label("auth_sign_in_apple".localized, systemImage: "apple.logo")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            VStack(alignment: .leading, spacing: 12) {
                Text("auth_or".localized)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                TextField("auth_email_placeholder".localized, text: $viewModel.email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
                Button("auth_sign_in_email".localized) {
                    Task { await viewModel.signInWithEmail() }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .alert(item: $viewModel.error) { error in
            Alert(title: Text(error.title), message: Text(error.message), dismissButton: .default(Text("ok".localized)))
        }
        .onReceive(viewModel.$signedInUser.compactMap { $0 }) { user in
            environment.sessionState = .authenticated(user)
        }
    }
}

#Preview {
    AuthView(viewModel: AuthViewModel(authService: MockAuthService()))
        .environmentObject(ApplicationEnvironment.preview)
}
