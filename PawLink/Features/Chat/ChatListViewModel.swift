import Foundation

@MainActor
final class ChatListViewModel: ObservableObject {
    @Published var chats: [ChatSummary] = []
    @Published var isLoading = false

    private let chatService: ChatService
    private let analytics: AnalyticsService

    init(chatService: ChatService, analytics: AnalyticsService) {
        self.chatService = chatService
        self.analytics = analytics
    }

    func load(for userId: UUID?) async {
        guard let userId else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            chats = try await chatService.fetchChats(for: userId)
        } catch {
            print("Chat load error: \(error)")
        }
    }
}
