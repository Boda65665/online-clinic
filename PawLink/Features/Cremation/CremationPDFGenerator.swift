import Foundation
import UIKit
import PDFKit

final class CremationPDFGenerator {
    func generate(order: CremationOrder) -> URL? {
        let bounds = CGRect(x: 0, y: 0, width: 612, height: 792)

        let renderer = UIGraphicsPDFRenderer(bounds: bounds)
        let data = renderer.pdfData { context in
            context.beginPage()
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .left

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.preferredFont(forTextStyle: .title1),
                .paragraphStyle: paragraph
            ]
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .paragraphStyle: paragraph
            ]

            let text = NSMutableAttributedString(string: "PawLink\n", attributes: titleAttributes)
            text.append(NSAttributedString(string: "\nКвитанция кремации\n\n", attributes: titleAttributes))
            text.append(NSAttributedString(string: "Номер заказа: \(order.id.uuidString)\n", attributes: bodyAttributes))
            text.append(NSAttributedString(string: "Питомец ID: \(order.petId.uuidString)\n", attributes: bodyAttributes))
            text.append(NSAttributedString(string: "Вес: \(order.weightKg) кг\n", attributes: bodyAttributes))
            text.append(NSAttributedString(string: "Пакет: \(order.packageType.localizedTitle)\n", attributes: bodyAttributes))
            text.append(NSAttributedString(string: "Контакт: \(order.contactName)\n", attributes: bodyAttributes))
            text.append(NSAttributedString(string: "Телефон: \(order.contactPhone)\n", attributes: bodyAttributes))
            text.append(NSAttributedString(string: "Email: \(order.contactEmail)\n", attributes: bodyAttributes))
            text.append(NSAttributedString(string: "Дата забора: \(DateFormatter.localizedString(from: order.pickupAt, dateStyle: .medium, timeStyle: .short))\n\n", attributes: bodyAttributes))
            text.append(NSAttributedString(string: "Статус: \(order.status.timelineTitle)\n", attributes: bodyAttributes))
            text.append(NSAttributedString(string: "Пожелания: \(order.wishes ?? "-")\n\n", attributes: bodyAttributes))
            text.append(NSAttributedString(string: "Demo", attributes: [
                .font: UIFont.boldSystemFont(ofSize: 36),
                .foregroundColor: UIColor.systemTeal
            ]))

            text.draw(in: bounds.insetBy(dx: 32, dy: 64))
        }

        let tempURL = FileManager.default.temporaryDirectory.appending(path: "cremation_\(order.id).pdf")
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            return nil
        }
    }
}
