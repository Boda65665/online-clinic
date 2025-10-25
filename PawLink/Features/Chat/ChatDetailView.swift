import SwiftUI

struct ChatDetailView: View {
    @StateObject var viewModel: ChatDetailViewModel
    @EnvironmentObject private var environment: ApplicationEnvironment

    init(viewModel: ChatDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages, id: \.id) { message in
                            HStack {
                                if isCurrentUser(message: message) { Spacer() }
                                Text(message.content)
                                    .padding(12)
                                    .background(isCurrentUser(message: message) ? Color.accentColor.opacity(0.2) : Color(.secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                if !isCurrentUser(message: message) { Spacer() }
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let last = viewModel.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }
            HStack {
                TextField("chat_placeholder".localized, text: $viewModel.inputText)
                    .textFieldStyle(.roundedBorder)
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                }
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .task { await viewModel.load() }
        .navigationTitle("chat_detail_title".localized)
    }

    private func isCurrentUser(message: Message) -> Bool {
        if case let .authenticated(user) = environment.sessionState {
            return message.senderId == user.id
        }
        return false
    }

    private func sendMessage() {
        if case let .authenticated(user) = environment.sessionState {
            Task { await viewModel.sendMessage(from: user) }
        }
    }
}

#Preview {
    ChatDetailView(viewModel: ChatDetailViewModel(chatService: MockChatService(), chat: ChatSummary(id: UUID(), walker: MockData.walkers().first!, lastMessage: nil)))
        .environmentObject(ApplicationEnvironment.preview)
}
