import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 24) {
            TabView(selection: $viewModel.step) {
                roleStep
                    .tag(OnboardingViewModel.Step.role)
                permissionsStep
                    .tag(OnboardingViewModel.Step.permissions)
                summaryStep
                    .tag(OnboardingViewModel.Step.summary)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.25), value: viewModel.step)

            Button(action: viewModel.continueFlow) {
                Text(viewModel.step == .summary ? "onboarding_finish".localized : "next".localized)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
        }
        .padding()
        .navigationTitle("onboarding_title".localized)
    }

    private var roleStep: some View {
        VStack(spacing: 16) {
            Text("onboarding_choose_role".localized)
                .font(.title2)
                .padding(.bottom, 12)
            HStack(spacing: 16) {
                roleCard(role: .owner)
                roleCard(role: .walker)
            }
        }
    }

    private func roleCard(role: UserRole) -> some View {
        VStack(spacing: 12) {
            Image(systemName: role == .owner ? "house.fill" : "figure.walk")
                .font(.largeTitle)
                .foregroundStyle(Color.accentColor)
            Text(role == .owner ? "role_owner".localized : "role_walker".localized)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(viewModel.selectedRole == role ? Color.accentColor.opacity(0.15) : Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .onTapGesture {
            withAnimation { viewModel.selectedRole = role }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(viewModel.selectedRole == role ? .isSelected : [])
    }

    private var permissionsStep: some View {
        VStack(spacing: 20) {
            Text("onboarding_permissions_title".localized)
                .font(.title2)
            Toggle(isOn: $viewModel.notificationsGranted) {
                Text("onboarding_notifications".localized)
            }
            .toggleStyle(.switch)
            .onChange(of: viewModel.notificationsGranted) { granted in
                if granted { Task { await viewModel.requestNotifications() } }
            }

            Toggle(isOn: $viewModel.locationGranted) {
                Text("onboarding_location".localized)
            }
            .toggleStyle(.switch)
            .onChange(of: viewModel.locationGranted) { granted in
                if granted { Task { await viewModel.requestLocation() } }
            }
        }
    }

    private var summaryStep: some View {
        VStack(spacing: 16) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.accentColor)
            Text("onboarding_ready".localized)
                .font(.title2)
                .multilineTextAlignment(.center)
            Text("onboarding_summary".localized)
                .font(.body)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    OnboardingView(viewModel: ApplicationEnvironment.preview.makeOnboardingViewModel())
}
