import SwiftUI
import SwiftData
import Combine

final class ChatListViewModel: ObservableObject {
    @Published var messagesByChat: [UUID: [Message]] = [:]
    @Published var chats: [UUID] = []
    @Published var isLoading = false
    @Published var error: AppError?

    private let chatService: ChatService
    let currentUser: User
    private var cancellables = Set<AnyCancellable>()

    init(currentUser: User, chatService: ChatService = MockChatService()) {
        self.currentUser = currentUser
        self.chatService = chatService
        loadChats()
    }

    private func loadChats() {
        isLoading = true
        let context = ModelContext(AppModelContainer.shared.container)
        let descriptor = FetchDescriptor<Booking>()
        if let bookings = try? context.fetch(descriptor).filter({ $0.ownerId == currentUser.id || $0.walkerId == currentUser.id }) {
            self.chats = bookings.map { $0.chatId }
            bookings.forEach { booking in
                chatService.fetchMessages(chatId: booking.chatId)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] completion in
                        self?.isLoading = false
                        if case .failure(let error) = completion {
                            self?.error = error
                        }
                    } receiveValue: { [weak self] messages in
                        self?.messagesByChat[booking.chatId] = messages
                    }
                    .store(in: &cancellables)
            }
        }
        isLoading = false
    }
}

final class ChatThreadViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var draft: String = ""

    private let chatId: UUID
    private let chatService: ChatService
    let currentUser: User
    private var cancellables = Set<AnyCancellable>()

    init(chatId: UUID, currentUser: User, chatService: ChatService = MockChatService()) {
        self.chatId = chatId
        self.currentUser = currentUser
        self.chatService = chatService
        fetch()
    }

    func fetch() {
        chatService.fetchMessages(chatId: chatId)
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { [weak self] messages in
                self?.messages = messages
            }
            .store(in: &cancellables)
    }

    func send() {
        guard !draft.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let message = Message(chatId: chatId, senderId: currentUser.id, content: draft)
        chatService.send(message: message)
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { [weak self] message in
                self?.messages.append(message)
                self?.draft = ""
            }
            .store(in: &cancellables)
    }
}

struct ChatListView: View {
    @StateObject var viewModel: ChatListViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.chats, id: \.self) { chatId in
                    if let messages = viewModel.messagesByChat[chatId], let last = messages.last {
                        NavigationLink(destination: ChatThreadView(viewModel: ChatThreadViewModel(chatId: chatId, currentUser: viewModel.viewContextUser))) {
                            VStack(alignment: .leading) {
                                Text(NSLocalizedString("chat.conversation", comment: "") + " #" + chatId.uuidString.prefix(4))
                                    .font(.title3)
                                Text(last.content)
                                    .font(.footnote)
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle(Text(NSLocalizedString("chat.title", comment: "")))
            .overlay { if viewModel.isLoading { ProgressView() } }
        }
    }
}

private extension ChatListViewModel {
    var viewContextUser: User { currentUser }
}

struct ChatThreadView: View {
    @ObservedObject var viewModel: ChatThreadViewModel

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages, id: \.id) { message in
                            HStack {
                                if message.senderId == viewModel.currentUser.id {
                                    Spacer()
                                }
                                Text(message.content)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).fill(message.senderId == viewModel.currentUser.id ? Color(.systemTeal).opacity(0.2) : Color(.systemGray6)))
                                if message.senderId != viewModel.currentUser.id {
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            HStack {
                TextField(NSLocalizedString("chat.message.placeholder", comment: ""), text: $viewModel.draft)
                    .textFieldStyle(.roundedBorder)
                Button(action: viewModel.send) {
                    Image(systemName: "paperplane.fill")
                }
                .disabled(viewModel.draft.isEmpty)
            }
            .padding()
        }
        .navigationTitle(Text(NSLocalizedString("chat.conversation", comment: "")))
    }
}
