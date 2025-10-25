import SwiftUI
import PDFKit

struct CremationDetailView: View {
    @StateObject var viewModel: CremationDetailViewModel
    @EnvironmentObject private var environment: ApplicationEnvironment

    init(viewModel: CremationDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            Section(header: Text("cremation_timeline".localized)) {
                ForEach(viewModel.timeline, id: \.self) { status in
                    HStack {
                        Circle()
                            .fill(status == viewModel.order.status ? Color.accentColor : Color.gray.opacity(0.3))
                            .frame(width: 12, height: 12)
                        Text(status.rawValue.capitalized)
                        Spacer()
                        if status == viewModel.order.status {
                            Text("status_current".localized)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section(header: Text("cremation_details".localized)) {
                Text(viewModel.order.pickupAddress)
                Text(viewModel.order.contactName)
                Text(viewModel.order.contactPhone)
                Text(viewModel.order.contactEmail)
            }

            Section {
                Button("cremation_generate_pdf".localized) {
                    if case let .authenticated(user) = environment.sessionState {
                        viewModel.generatePDF(owner: user)
                    }
                }
                if let data = viewModel.generatedPDF, let url = saveTemporary(data: data) {
                    ShareLink(item: url, preview: SharePreview("PDF", image: Image(systemName: "doc.richtext")))
                }
            }
        }
        .navigationTitle("cremation_detail_title".localized)
    }

    private func saveTemporary(data: Data) -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("cremation.pdf")
        try? data.write(to: url)
        return url
    }
}

#Preview {
    CremationDetailView(viewModel: CremationDetailViewModel(order: MockData.cremationOrders(owner: MockData.previewOwner, pets: MockData.pets(owner: MockData.previewOwner)).first!, service: MockCremationService(), pdfGenerator: CremationPDFGenerator(), notificationService: MockNotificationService()))
        .environmentObject(ApplicationEnvironment.preview)
}
