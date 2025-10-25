import Foundation
import UserNotifications

final class MockNotificationService: NotificationService {
    func requestAuthorization() async {
        let center = UNUserNotificationCenter.current()
        _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
    }

    func scheduleReminder(for booking: Booking) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification.booking.title", comment: "")
        content.body = NSLocalizedString("notification.booking.body", comment: "")
        schedule(identifier: booking.id.uuidString, date: booking.start.addingTimeInterval(-3600), content: content)
    }

    func scheduleReminder(for order: CremationOrder) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification.cremation.title", comment: "")
        content.body = NSLocalizedString("notification.cremation.body", comment: "")
        schedule(identifier: order.id.uuidString + ".24h", date: order.pickupAt.addingTimeInterval(-86400), content: content)
        schedule(identifier: order.id.uuidString + ".2h", date: order.pickupAt.addingTimeInterval(-7200), content: content)
    }

    private func schedule(identifier: String, date: Date, content: UNNotificationContent) {
        guard date > .now else { return }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(5, date.timeIntervalSinceNow), repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
