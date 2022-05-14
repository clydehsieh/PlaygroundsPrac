import UIKit

var nums = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

// contain
if nums.contains(1) {
    debugPrint("contain 1")
}

// filter
var lessThan5 = nums.filter({ $0 < 5 })
debugPrint(lessThan5)

// empty
if nums.isEmpty {
    debugPrint("empty")
} else {
    debugPrint("not empty")
}

// shuffle
let shuffled = nums.shuffled()
debugPrint("shuffled \(shuffled)\n")

// firstIndexOf
let firstIndex = shuffled.firstIndex(where: { $0 == 5 })
debugPrint("first 5 Index \(firstIndex ?? 0)")

// sort
var sorted = shuffled.sorted(by: { $0 > $1 })

// reverse
sorted.reverse()

// allSatisfy
let allSatisfy = sorted.allSatisfy({ $0 < 10})
debugPrint("allSatisfy \(allSatisfy)\n")

// map
let mapArray = sorted.map({ "num \($0)" })

// forEach
mapArray.forEach { content in
    debugPrint(content)
}

// reduce
let total = sorted.reduce(0.0) { (partialResult, num) -> CGFloat in
    partialResult + CGFloat(num)
}

// first
let first = sorted.first

// randomElement
let radom = sorted.randomElement()

// Slice
let arraySliceStyle1 = sorted.prefix(3)
let arraySliceStyle2 = sorted[0..<3]

// subscript - safe
extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        
        return self[index]
    }
}

let safeElement = sorted[safe: 20]

// subscript - safe bounds
extension Array where Element : Equatable {
    public subscript(safe bounds: Range<Int>) -> ArraySlice<Element> {
        if bounds.lowerBound > count { return [] }
        let lower = Swift.max(0, bounds.lowerBound)
        let upper = Swift.max(0, Swift.min(count, bounds.upperBound))
        return self[lower..<upper]
    }
    
    public subscript(safe lower: Int?, _ upper: Int?) -> ArraySlice<Element> {
        let lower = lower ?? 0
        let upper = upper ?? count
        if lower > upper { return [] }
        return self[safe: lower..<upper]
    }
}

let safeSlice = sorted[safe: 0..<30]

// subscript - safe bounds
enum Level {
    case lower(value: Int)
    case middle(value: Int)
    case higher(value: Int)
}

extension Array where Element == Int {
    subscript(type: Level) -> [Element] {
        switch type {
        case let .lower(value):
            return self.filter({ $0 < value })
        case let .middle(value):
            return self.filter({ $0 == value })
        case let .higher(value):
            return self.filter({ $0 > value })
        }
    }
}

let lowSlice = sorted[.lower(value: 5)]
