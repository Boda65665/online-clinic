import SwiftUI

struct PaymentView: View {
    @ObservedObject var viewModel: BookingDetailsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isProcessing = false
    @State private var success = false

    var body: some View {
        VStack(spacing: 24) {
            Text(NSLocalizedString("payment.summary", comment: ""))
                .font(.title2)
                .bold()

            Text("₽\(Int(viewModel.price))")
                .font(.largeTitle)
                .bold()

            if success {
                Image(systemName: "checkmark.seal.fill").font(.system(size: 64)).foregroundColor(.green)
                Text(NSLocalizedString("payment.success", comment: ""))
            }

            Button {
                isProcessing = true
                viewModel.proceedPayment { result in
                    isProcessing = false
                    switch result {
                    case .success:
                        success = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { dismiss() }
                    case .failure(let error):
                        viewModel.error = error
                    }
                }
            } label: {
                Text(success ? NSLocalizedString("payment.done", comment: "") : NSLocalizedString("payment.applepay", comment: ""))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isProcessing || success)

            Spacer()
        }
        .padding()
        .overlay {
            if isProcessing { ProgressView() }
        }
        .alert(viewModel.error?.localizedDescription ?? "", isPresented: Binding(get: { viewModel.error != nil }, set: { if !$0 { viewModel.error = nil } })) {
            Button("OK", role: .cancel) { viewModel.error = nil }
        }
    }
}
