import Foundation
import Combine
import SwiftData

final class MockCremationService: CremationService {
    private let context = ModelContext(AppModelContainer.shared.container)

    func fetchOrders(ownerId: UUID) -> AnyPublisher<[CremationOrder], AppError> {
        Future { promise in
            let descriptor = FetchDescriptor<CremationOrder>()
            do {
                let orders = try self.context.fetch(descriptor).filter { $0.ownerId == ownerId }
                    .sorted(by: { $0.pickupAt < $1.pickupAt })
                promise(.success(orders))
            } catch {
                promise(.failure(.unknown))
            }
        }
        .eraseToAnyPublisher()
    }

    func create(order: CremationOrder) -> AnyPublisher<CremationOrder, AppError> {
        Future { promise in
            self.context.insert(order)
            do {
                try self.context.save()
                promise(.success(order))
            } catch {
                promise(.failure(.unknown))
            }
        }
        .eraseToAnyPublisher()
    }

    func update(order: CremationOrder) -> AnyPublisher<CremationOrder, AppError> {
        Future { promise in
            do {
                order.updatedAt = .now
                try self.context.save()
                promise(.success(order))
            } catch {
                promise(.failure(.unknown))
            }
        }
        .eraseToAnyPublisher()
    }
}
