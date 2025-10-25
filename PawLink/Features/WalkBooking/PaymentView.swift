import SwiftUI
import PassKit

struct PaymentView: View {
    @StateObject var viewModel: PaymentViewModel
    var onPaid: (Booking) -> Void

    init(viewModel: PaymentViewModel, onPaid: @escaping (Booking) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onPaid = onPaid
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("payment_total".localized + " \(viewModel.booking.price as NSDecimalNumber) ₽")
                .font(.title2)
            Button("payment_apple_pay".localized) {
                Task { await viewModel.pay(completion: onPaid) }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .overlay {
            if viewModel.isProcessing {
                ProgressView()
            }
        }
        .alert(item: $viewModel.error) { error in
            Alert(title: Text(error.title), message: Text(error.message), dismissButton: .default(Text("ok".localized)))
        }
    }
}

#Preview {
    PaymentView(viewModel: PaymentViewModel(booking: MockData.bookings(owner: MockData.previewOwner, walker: MockData.walkers().first!, pet: MockData.pets(owner: MockData.previewOwner).first!).first!, paymentManager: PaymentManager(service: MockPaymentService()), analytics: MockAnalyticsService()), onPaid: { _ in })
}
