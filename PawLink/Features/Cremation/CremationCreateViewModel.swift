import Foundation

@MainActor
final class CremationCreateViewModel: ObservableObject {
    @Published var selectedPetId: UUID?
    @Published var weightText: String = ""
    @Published var address: String = ""
    @Published var contactName: String = ""
    @Published var contactPhone: String = ""
    @Published var contactEmail: String = ""
    @Published var package: CremationPackage = .standard
    @Published var wishes: String = ""
    @Published var pickupAt: Date = Date().addingTimeInterval(86400)
    @Published var consentAccepted: Bool = false
    @Published var error: AppError?
    @Published var isLoading = false

    private let service: CremationService
    private let analytics: AnalyticsService
    private let notificationService: NotificationService
    private let validation: ValidationService

    init(service: CremationService, analytics: AnalyticsService, notificationService: NotificationService, validation: ValidationService) {
        self.service = service
        self.analytics = analytics
        self.notificationService = notificationService
        self.validation = validation
    }

    func submit(owner: User) async -> CremationOrder? {
        guard let weight = Double(weightText), validation.validateWeight(weight) else {
            error = AppError(title: "cremation_error".localized, message: "cremation_weight_invalid".localized)
            return nil
        }
        guard validation.validateFuture(date: pickupAt) else {
            error = AppError(title: "cremation_error".localized, message: "cremation_date_invalid".localized)
            return nil
        }
        guard validation.validatePhone(contactPhone) else {
            error = AppError(title: "cremation_error".localized, message: "cremation_phone_invalid".localized)
            return nil
        }
        guard validation.validateEmail(contactEmail) else {
            error = AppError(title: "cremation_error".localized, message: "cremation_email_invalid".localized)
            return nil
        }
        guard !address.isEmpty else {
            error = AppError(title: "cremation_error".localized, message: "booking_address_required".localized)
            return nil
        }
        guard !contactName.isEmpty else {
            error = AppError(title: "cremation_error".localized, message: "cremation_contact_name".localized)
            return nil
        }
        guard consentAccepted else {
            error = AppError(title: "cremation_error".localized, message: "cremation_consent_required".localized)
            return nil
        }

        isLoading = true
        defer { isLoading = false }
        let input = CremationInput(ownerId: owner.id, petId: selectedPetId, weightKg: weight, pickupAddress: address, contactName: contactName, contactPhone: contactPhone, contactEmail: contactEmail, package: package, wishes: wishes.isEmpty ? nil : wishes, pickupAt: pickupAt)
        do {
            let order = try await service.createOrder(input)
            try? await notificationService.scheduleLocalNotification(at: Calendar.current.date(byAdding: .hour, value: -24, to: pickupAt) ?? pickupAt, title: "cremation_reminder_title".localized, body: "cremation_reminder_body_day".localized, identifier: order.id.uuidString + "-24")
            try? await notificationService.scheduleLocalNotification(at: Calendar.current.date(byAdding: .hour, value: -2, to: pickupAt) ?? pickupAt, title: "cremation_reminder_title".localized, body: "cremation_reminder_body_2h".localized, identifier: order.id.uuidString + "-2")
            await analytics.track(event: .cremationCreated)
            return order
        } catch {
            self.error = AppError(error)
            return nil
        }
    }
}
