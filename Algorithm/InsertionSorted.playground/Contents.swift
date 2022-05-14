import UIKit

func insertionSort(_ array: [Int]) -> [Int] {
    var sortedArray = array
    
    for index in 1..<sortedArray.count {
        var currentIndex = index
        while currentIndex > 0, sortedArray[currentIndex - 1] > sortedArray[currentIndex] {
            sortedArray.swapAt(currentIndex - 1, currentIndex)
            currentIndex -= 1
        }
    }
    
    return sortedArray
}

let originArray = [1,6,3,8,9,4,10,2]
insertionSort(originArray)


func insertionSort<T>(_ array: [T],_ isOrderedBefore: (T, T) -> Bool) -> [T] {
    var sortedArray = array
    
    for index in 1..<sortedArray.count {
        var currentIndex = index
        
        while currentIndex > 0,
                isOrderedBefore(sortedArray[currentIndex], sortedArray[currentIndex - 1]) {
            sortedArray.swapAt(currentIndex - 1, currentIndex)
            currentIndex -= 1
        }
    }
    
    return sortedArray
}

insertionSort(originArray, <)
insertionSort(originArray, >)
