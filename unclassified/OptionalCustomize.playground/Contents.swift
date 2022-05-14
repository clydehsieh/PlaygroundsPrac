import UIKit

extension Int {
    init?(_ value: Coptional<Int>) {
        switch value {
        case .none:
            return nil
        case let .some(value):
            self = value
        }
    }
}

@frozen enum Coptional<Wrapped> {
    case some(Wrapped)
    case none

    public init(_ some: Wrapped) {
        self = .some(some)
    }

    // pattern-matching for nil
    static func ~= (lhs: _OptionalNilComparisonType, rhs: Coptional<Wrapped>) -> Bool {
        switch rhs {
        case .none:
            return true
        default:
            return false
        }
    }
    
    // pattern-matching for value
    static func ~= (lhs: Wrapped, rhs: Coptional<Wrapped>) -> Bool where Wrapped: Equatable  {
        switch rhs {
        case let .some(value):
            return value == lhs
        default:
            return false
        }
    }
}

let optionalSomeA: Int? = 24
let optionalSomeB: Int? = Optional.some(24)
let optionalSomeC: Coptional<Int> = .init(24)


let optionalNilB: Int? = Optional.none
let optionalNilD: Coptional<Int> = .none

// Literal/ Int
extension Coptional: ExpressibleByNilLiteral {
    init(nilLiteral: ()) {
        self = .none
    }
}
let optionalNilLiteralA: Int? = nil
let optionalNilLiteralB: Coptional<Int> = nil


extension Coptional: ExpressibleByIntegerLiteral {
    typealias IntegerLiteralType = Int
    init(integerLiteral value: IntegerLiteralType) {
        self = .some(value as! Wrapped)
    }
}
let integerLiteralA: Int? = 24
let integerLiteralB: Coptional<Int> = 24


// pattern-matching for value
switch integerLiteralB {
case 24:
    debugPrint("ya 24")
default:
    debugPrint("no 24")
}

// pattern-matching for nil
switch optionalNilLiteralB {
case .none:
    debugPrint("no")
default:
    debugPrint("ya")
}
