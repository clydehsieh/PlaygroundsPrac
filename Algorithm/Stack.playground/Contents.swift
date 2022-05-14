import UIKit

public struct Stack<T> {
    fileprivate var array = [T]()
    
    public var isEmpty: Bool {
        array.isEmpty
    }
    
    public var count: Int {
        array.count
    }
    
    public var top: T? {
        array.last
    }
    
    public mutating func push(_ element: T) {
        array.append(element)
    }
    
    public mutating func pop() {
        array.popLast()
    }
}
