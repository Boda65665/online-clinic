import Foundation
import Combine
import SwiftData

final class MockWalkerService: WalkerService {
    private let context = ModelContext(AppModelContainer.shared.container)

    func fetchWalkers() -> AnyPublisher<[Walker], AppError> {
        Future { promise in
            let descriptor = FetchDescriptor<Walker>()
            do {
                let walkers = try self.context.fetch(descriptor)
                promise(.success(walkers))
            } catch {
                promise(.failure(.unknown))
            }
        }
        .eraseToAnyPublisher()
    }

    func fetchWalker(by id: UUID) -> AnyPublisher<Walker, AppError> {
        Future { promise in
            let descriptor = FetchDescriptor<Walker>()
            do {
                let walkers = try self.context.fetch(descriptor)
                if let walker = walkers.first(where: { $0.id == id }) {
                    promise(.success(walker))
                } else {
                    promise(.failure(.network(NSLocalizedString("walker.notfound", comment: ""))))
                }
            } catch {
                promise(.failure(.unknown))
            }
        }
        .eraseToAnyPublisher()
    }
}
