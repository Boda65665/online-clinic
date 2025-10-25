# PawLink

PawLink is a SwiftUI iOS demo app (Swift 5.9+, iOS 17+) showcasing an MVVM + Coordinator architecture for connecting pet owners with walkers and providing a cremation scheduling module. The project uses SwiftData for persistence, Combine for reactivity, and URLSession-based mock services.

## Features
- Onboarding with role selection, permissions, and Sign in with Apple stub.
- Map-based discovery of walkers using MapKit with filter pills and bottom sheets.
- Booking flow (slot selection, booking details, Apple Pay mock, status timeline).
- Chat between owner and walker persisted with SwiftData mocks.
- Reviews with rating aggregation.
- Cremation scheduling module with calendar filters, PDF receipt generation (PDFKit), and local notification scheduling.
- Settings with role switching, localization (ru/en), and privacy/terms placeholders.
- Analytics protocol with mock implementation and DI-friendly services.

## Architecture
- **App/**: Entry point (`PawLinkApp`), coordinator, root view.
- **Core/**: Helpers, theme, shared modifiers.
- **Data/**: SwiftData models and seeding (`AppModelContainer`).
- **Networking/**: Service protocols and mock implementations with Combine publishers (ready to be replaced by real URLSession layers).
- **Features/**: Modular folders for Onboarding, Auth, MapSearch, WalkBooking, Chat, Reviews, Cremation.
- **Services/**: Payment, Notifications, Analytics, Location, Auth abstractions.
- **Resources/**: Assets, localization, Info.plist, privacy/terms placeholders.
- **Tests/**: Basic unit tests for key view models and validation logic.

## Dependencies & Requirements
- Xcode 15 or later, iOS 17+ target.
- SwiftData, MapKit, Combine, PDFKit, PassKit, AuthenticationServices, CoreLocation, UserNotifications.
- No external package dependencies.

## Setup
1. Open `PawLink/PawLink.xcodeproj` in Xcode.
2. Select the `PawLink` scheme and run on an iOS 17+ simulator or device.
3. Mock data is seeded automatically using `SampleDataSeeder` when the app launches in-memory.

## Extending to Real Backend
- Implement remote services conforming to protocols in `Networking/Protocols/Services.swift` using URLSession.
- Replace `MockAuthService` with Sign in with Apple server validation and secure token storage (Keychain stub ready).
- Swap `MockPaymentService` with real Apple Pay integration in `PaymentManager`.
- Add Firebase/CloudKit by implementing analytics or persistence providers using the existing abstractions.

## Testing
- Unit tests are included in `Tests/ViewModelTests.swift` covering booking price, cremation validation, reviews, chat sending, and data fetch flows.

## TODO
- Integrate live backend endpoints (`Remote*Service`).
- Add snapshot/UI tests and full Apple Pay integration.
- Expand accessibility auditing and add VoiceOver-specific content descriptions.
