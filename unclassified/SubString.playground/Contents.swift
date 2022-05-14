import UIKit

var greeting = "Hello, playground"
let charactor = greeting[greeting.index(greeting.startIndex, offsetBy: 0)]

let wordStartIndex = greeting.index(greeting.startIndex, offsetBy: 0)
let wordEndIndex   = greeting.index(greeting.startIndex, offsetBy: 5)
let word = greeting[wordStartIndex..<wordEndIndex]

