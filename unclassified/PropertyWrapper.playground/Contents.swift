import Foundation
import Combine
import UIKit

//MARK: - basic
/*
 wrappedValue
 projectedValue
 
 */
@propertyWrapper
struct Limit {
    private var max: CGFloat
    private var value: CGFloat
    
    var wrappedValue: CGFloat {
        get {
            value
        }
        set {
            value = min(max, newValue)
        }
    }
    
    init(maxValue: CGFloat) {
        self.max = maxValue
        self.value = 0
    }
    
    var projectedValue: CGFloat {
        max
    }
}

class Rectangle {
    @Limit(maxValue: 10) var height: CGFloat
    @Limit(maxValue: 15) var width: CGFloat
    
    init(height: CGFloat, width: CGFloat) {
        self.height = height
        self.width = width
    }
    
    func area() -> CGFloat {
        height * width
    }
}

let rect = Rectangle(height: 5, width: 50)
rect.height
rect.$height
rect.width
rect.$width
