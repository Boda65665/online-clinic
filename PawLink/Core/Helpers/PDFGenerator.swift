import Foundation
import PDFKit

struct CremationPDFGenerator {
    func makePDF(for order: CremationOrder, pet: Pet?, owner: User) -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "PawLink",
            kCGPDFContextAuthor: owner.name,
            kCGPDFContextTitle: "Cremation Order"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        return renderer.pdfData { context in
            context.beginPage()
            let title = "PawLink Cremation"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.preferredFont(forTextStyle: .title1)
            ]
            title.draw(at: CGPoint(x: 40, y: 40), withAttributes: titleAttributes)

            var yOffset: CGFloat = 120
            func draw(_ text: String) {
                let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .body)]
                text.draw(at: CGPoint(x: 40, y: yOffset), withAttributes: attributes)
                yOffset += 28
            }

            draw("Order ID: \(order.id.uuidString)")
            draw("Owner: \(owner.name)")
            draw("Pet: \(pet?.name ?? "-")")
            draw("Weight: \(order.weightKg) кг")
            draw("Package: \(order.package.rawValue)")
            draw("Pickup: \(order.pickupAt.formatted(date: .numeric, time: .shortened))")
            draw("Address: \(order.pickupAddress)")
            if let wishes = order.wishes {
                draw("Wishes: \(wishes)")
            }
            draw("Status: \(order.status.rawValue)")

            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.preferredFont(forTextStyle: .footnote)
            ]
            let footer = "Demo"
            footer.draw(at: CGPoint(x: pageRect.midX - 30, y: pageRect.height - 60), withAttributes: footerAttributes)
        }
    }
}
