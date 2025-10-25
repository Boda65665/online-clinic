import SwiftUI

struct AuthView: View {
    let completion: (AuthResult) -> Void

    var body: some View {
        OnboardingView(completion: completion)
    }
}
