import Foundation

@MainActor
final class ChatDetailViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputText: String = ""

    private let chatService: ChatService
    private let chat: ChatSummary

    init(chatService: ChatService, chat: ChatSummary) {
        self.chatService = chatService
        self.chat = chat
    }

    func load() async {
        do {
            messages = try await chatService.messages(for: chat.id)
        } catch {
            print("Failed to load messages: \(error)")
        }
    }

    func sendMessage(from user: User) async {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let message = Message(id: UUID(), chatId: chat.id, senderId: user.id, content: inputText, createdAt: Date(), isRead: false)
        do {
            try await chatService.send(message: message)
            await load()
            inputText = ""
        } catch {
            print("Failed to send message: \(error)")
        }
    }
}
