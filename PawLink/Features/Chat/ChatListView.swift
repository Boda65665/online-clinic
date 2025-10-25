import SwiftUI

struct ChatListView: View {
    @StateObject var viewModel: ChatListViewModel
    @EnvironmentObject private var environment: ApplicationEnvironment

    init(viewModel: ChatListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List(viewModel.chats) { chat in
                NavigationLink(destination: ChatDetailView(viewModel: ChatDetailViewModel(chatService: environment.services.chat, chat: chat))) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(chat.walker.bio)
                            .font(.headline)
                        if let last = chat.lastMessage {
                            Text(last.content)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .task {
                if case let .authenticated(user) = environment.sessionState {
                    await viewModel.load(for: user.id)
                }
            }
            .navigationTitle("chat_tab_title".localized)
        }
    }
}

#Preview {
    ChatListView(viewModel: ChatListViewModel(chatService: MockChatService(), analytics: MockAnalyticsService()))
        .environmentObject(ApplicationEnvironment.preview)
}
