import XCTest
@testable import PawLink

final class ChatDetailViewModelTests: XCTestCase {
    func testSendMessageAppends() async throws {
        let chatService = MockChatService()
        try await chatService.prepareInitialData()
        let owner = MockData.previewOwner
        let walker = MockData.walkers().first!
        let chat = ChatSummary(id: UUID(), walker: walker, lastMessage: nil)
        let viewModel = ChatDetailViewModel(chatService: chatService, chat: chat)
        await viewModel.load()
        XCTAssertEqual(viewModel.messages.count, 0)
        viewModel.inputText = "Hello"
        await viewModel.sendMessage(from: owner)
        await viewModel.load()
        XCTAssertEqual(viewModel.messages.count, 1)
    }
}
