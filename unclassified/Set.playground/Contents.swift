import UIKit

var set1 = Set([1, 2, 3])
var set2 = Set([2, 3, 4])

var result = set1.union(set2)
debugPrint("\(result), set1 \(set1)") // [1, 2, 3, 4]

result = set1.symmetricDifference(set2)
debugPrint("\(result), set1 \(set1)") // [1, 4]

result = set1.intersection(set2)
debugPrint("\(result), set1 \(set1)") // [2, 3]

result = set1.subtracting(set2)
debugPrint("\(result), set1 \(set1)") // [1]

let repeatedArray = [1,1, 3,9, 9, 7, 3, 1, 1, 9, 3, 4, 5, 5]
let nonRepeatedSet = Set(repeatedArray)
let orderAndNonRepeatedArry = nonRepeatedSet.sorted(by: <)
debugPrint("nonRepeatedSet \(nonRepeatedSet)")
debugPrint("orderAndNonRepeatedArry \(orderAndNonRepeatedArry)")
