import Foundation
import Combine
import SwiftData

final class MockChatService: ChatService {
    private let context = ModelContext(AppModelContainer.shared.container)

    func fetchMessages(chatId: UUID) -> AnyPublisher<[Message], AppError> {
        Future { promise in
            let descriptor = FetchDescriptor<Message>()
            do {
                let messages = try self.context.fetch(descriptor).filter { $0.chatId == chatId }
                    .sorted(by: { $0.createdAt < $1.createdAt })
                promise(.success(messages))
            } catch {
                promise(.failure(.unknown))
            }
        }
        .eraseToAnyPublisher()
    }

    func send(message: Message) -> AnyPublisher<Message, AppError> {
        Future { promise in
            self.context.insert(message)
            do {
                try self.context.save()
                promise(.success(message))
            } catch {
                promise(.failure(.unknown))
            }
        }
        .eraseToAnyPublisher()
    }
}
