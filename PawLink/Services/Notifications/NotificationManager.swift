import Foundation
import UserNotifications

final class NotificationManager {
    private let service: NotificationService

    init(service: NotificationService) {
        self.service = service
    }

    func requestPermissions() async {
        do {
            try await service.requestAuthorization()
        } catch {
            print("Notification permission error: \(error)")
        }
    }

    func scheduleBookingReminder(for booking: Booking) async {
        let oneHourBefore = Calendar.current.date(byAdding: .hour, value: -1, to: booking.start) ?? booking.start
        try? await service.scheduleLocalNotification(at: oneHourBefore, title: "booking_reminder_title".localized, body: "booking_reminder_body".localized, identifier: booking.id.uuidString)
    }

    func scheduleCremationReminders(for order: CremationOrder) async {
        let dayBefore = Calendar.current.date(byAdding: .hour, value: -24, to: order.pickupAt) ?? order.pickupAt
        let twoHoursBefore = Calendar.current.date(byAdding: .hour, value: -2, to: order.pickupAt) ?? order.pickupAt
        try? await service.scheduleLocalNotification(at: dayBefore, title: "cremation_reminder_title".localized, body: "cremation_reminder_body_day".localized, identifier: order.id.uuidString + "-24")
        try? await service.scheduleLocalNotification(at: twoHoursBefore, title: "cremation_reminder_title".localized, body: "cremation_reminder_body_2h".localized, identifier: order.id.uuidString + "-2")
    }
}
