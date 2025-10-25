import Foundation

@MainActor
final class CremationDetailViewModel: ObservableObject {
    @Published var order: CremationOrder
    @Published var isGeneratingPDF = false
    @Published var generatedPDF: Data?

    private let service: CremationService
    private let pdfGenerator: CremationPDFGenerator
    private let notificationService: NotificationService

    init(order: CremationOrder, service: CremationService, pdfGenerator: CremationPDFGenerator, notificationService: NotificationService) {
        self.order = order
        self.service = service
        self.pdfGenerator = pdfGenerator
        self.notificationService = notificationService
    }

    var timeline: [CremationStatus] {
        [.created, .scheduled, .picked_up, .in_progress, .completed, .delivered, .certificate_ready]
    }

    func generatePDF(owner: User) {
        isGeneratingPDF = true
        defer { isGeneratingPDF = false }
        let pet = MockData.pets(owner: owner).first { $0.id == order.petId }
        generatedPDF = pdfGenerator.makePDF(for: order, pet: pet, owner: owner)
    }
}
