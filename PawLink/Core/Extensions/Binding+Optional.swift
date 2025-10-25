import SwiftUI

extension Binding where Value: ExpressibleByNilLiteral {
    init(optional: Binding<Value?>) {
        self.init(get: { optional.wrappedValue ?? nil }, set: { newValue in
            optional.wrappedValue = newValue
        })
    }
}

extension Binding {
    static func fromOptional(_ optional: Binding<Value?>) -> Binding<Value?> {
        optional
    }
}
