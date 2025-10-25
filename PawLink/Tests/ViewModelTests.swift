import XCTest
@testable import PawLink

final class ViewModelTests: XCTestCase {
    func testBookingPriceCalculation() {
        let walker = Walker(userId: UUID(), ratePerHour: 1000, serviceArea: ServiceArea(centerLatitude: 0, centerLongitude: 0, radiusMeters: 1000), bio: "", ratingAvg: 4.5, reviewsCount: 10, isVerified: true, tags: [], availability: [])
        let user = User(role: .owner, name: "Test", email: "test@example.com", phone: "+1000000")
        let slot = TimeSlot(walkerId: walker.id, start: .now, end: .now.addingTimeInterval(3600), isBooked: false)
        let viewModel = BookingDetailsViewModel(walker: walker, user: user, slot: slot)
        viewModel.toggle(option: .photoReport)
        viewModel.calculatePrice()
        XCTAssertGreaterThan(viewModel.price, 0)
    }

    func testCremationValidationFails() {
        let owner = User(role: .owner, name: "Owner", email: "owner@example.com", phone: "+1000000")
        let viewModel = CremationCreateViewModel(owner: owner)
        viewModel.weight = "-1"
        viewModel.contactName = "Test"
        viewModel.phone = "123"
        viewModel.email = "invalid"
        viewModel.address = "Address"
        viewModel.consent = false
        viewModel.create(pet: nil)
        XCTAssertNotNil(viewModel.error)
    }

    func testReviewsSubmit() {
        let walker = Walker(userId: UUID(), ratePerHour: 1200, serviceArea: ServiceArea(centerLatitude: 0, centerLongitude: 0, radiusMeters: 1000), bio: "", ratingAvg: 4.5, reviewsCount: 10, isVerified: true, tags: [], availability: [])
        let owner = User(role: .owner, name: "Owner", email: "owner@example.com", phone: "+1000000")
        let viewModel = ReviewsViewModel(walker: walker, currentUser: owner)
        viewModel.comment = "Great"
        viewModel.rating = 5
        viewModel.submit()
        XCTAssertTrue(viewModel.reviews.contains { $0.comment == "Great" })
    }

    func testChatSend() {
        let user = User(role: .owner, name: "Owner", email: "owner@example.com", phone: "+1000000")
        let viewModel = ChatThreadViewModel(chatId: UUID(), currentUser: user)
        viewModel.draft = "Hello"
        viewModel.send()
        XCTAssertTrue(viewModel.messages.contains { $0.content == "Hello" })
    }

    func testMapFilters() {
        let vm = MapSearchViewModel()
        vm.filters = [.verified]
        XCTAssertNotNil(vm.filteredWalkers)
    }

    func testWalksFetch() {
        let user = User(role: .owner, name: "Owner", email: "owner@example.com", phone: "+1000000")
        let vm = WalksHomeViewModel(currentUser: user)
        vm.fetch()
        XCTAssertGreaterThanOrEqual(vm.bookings.count, 0)
    }
}
