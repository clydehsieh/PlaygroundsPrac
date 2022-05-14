import Foundation
import Combine
import UIKit

//MARK: -
protocol ObjectConvertible {
    init?(with object: Any)
    func object() -> Any?
}

extension ObjectConvertible {
    init?(with object: Any) {
        guard let object = object as? Self else { return nil }
        
        self = object
    }
    
    func object() -> Any? {
        self
    }
}

extension ObjectConvertible where Self: Codable {
    init?(with object: Any) {
        guard let codable = (object as? Data).flatMap({ try? JSONDecoder().decode(Self.self, from: $0) }) else { return nil }
        
        self = codable
    }
    
    func object() -> Any? {
        try? JSONEncoder().encode(self)
    }
}

extension Optional: ObjectConvertible where Wrapped: ObjectConvertible {
    init?(with object: Any) {
        guard let wrappwed = Wrapped(with: object) else { return nil }
        
        self = .some(wrappwed)
    }
    
    func object() -> Any? {
        switch self {
        case let .some(value):
            return value.object()
        case .none:
            return nil
        }
    }
}

extension Array: ObjectConvertible where Element: ObjectConvertible {
    init?(with object: Any) {
        guard let array = (object as? [Any])?.compactMap(Element.init) else { return nil }
        
        self = array
    }
    
    func object() -> Any? {
        compactMap { $0.object() }
    }
}

extension Dictionary: ObjectConvertible where Value: ObjectConvertible {
    init?(with object: Any) {
        guard let dictionary = (object as? [Key: Any])?.compactMapValues(Value.init) else { return nil }
        
        self = dictionary
    }
    
    func object() -> Any? {
        mapValues { $0.object() }
    }
}


extension String: ObjectConvertible {}
extension Bool: ObjectConvertible {}

@propertyWrapper
struct PropertyStroge<T: ObjectConvertible> {
    private var key: String
    private var defaults: UserDefaults
    private var data: T
    private var updateEventSubject: PassthroughSubject<T, Never> = .init()
    
    init(key: String, defaults: UserDefaults, defaultData: T) {
        self.key = key
        self.defaults = defaults
        self.data = defaultData
    }
    
    var wrappedValue: T {
        get {
            defaults.object(forKey: key).flatMap ({ T.init(with: $0) }) ?? data
        }
        set {
            data = newValue
//            defaults.set(newValue.object, forKey: key)
            updateEventSubject.send(newValue)
        }
    }
    
    var projectedValue: AnyPublisher<T, Never> {
        updateEventSubject.eraseToAnyPublisher()
    }
}

class UserDefaultHelper {
    static let shared = UserDefaultHelper()
    
    var subscriptions: Set<AnyCancellable> = .init()
    
    @PropertyStroge(key: "kName", defaults: UserDefaults.standard, defaultData: "Kitty")
    var name: String
    
    @PropertyStroge(key: "kIsMan", defaults: UserDefaults.standard, defaultData: false)
    var isMan: Bool
    
    init() { }
}

let helper = UserDefaultHelper.shared

helper.$name
    .sink { name in
        debugPrint( "Combine " + name)
    }.store(in: &helper.subscriptions)

debugPrint( "before " + helper.name)
helper.name = "Clyde"
debugPrint( "after " + helper.name)

