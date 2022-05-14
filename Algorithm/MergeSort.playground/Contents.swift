import UIKit

func mergeAndSord(_ array: [Int]) -> [Int] {
    
    print("splited array: \(array)")
    guard array.count > 1 else {
        return array
    }
    
    let middeleIndex = array.count / 2
    
    let left  = mergeAndSord(Array(array[0..<middeleIndex]))
    let right = mergeAndSord(Array(array[middeleIndex..<array.count]))
    
    return merge(left, right)
}

func merge(_ left: [Int], _ right: [Int]) -> [Int] {
    var leftIndex = 0
    var rightIndex = 0
    
    var result = [Int]()
    result.reserveCapacity(left.count + right.count)
    
    while leftIndex < left.count && rightIndex < right.count {
        if left[leftIndex] < right[rightIndex] {
            result.append(left[leftIndex])
            leftIndex += 1
        } else if left[leftIndex] > right[rightIndex] {
            result.append(right[rightIndex])
            rightIndex += 1
        } else {
            result.append(left[leftIndex])
            leftIndex += 1
            result.append(right[rightIndex])
            rightIndex += 1
        }
    }
    
    while leftIndex < left.count {
        result.append(left[leftIndex])
        leftIndex += 1
    }
    
    while rightIndex < right.count {
        result.append(right[rightIndex])
        rightIndex += 1
    }
    
    return result
}

let input = [12, 3, 13, 111, 987, 71, 17, 22, 3, 89, 18, 22]
let sorted = mergeAndSord(input)
print(sorted)

/*

 let input2 = [3, 7, 9, 4]
 
 [3, 7] [9, 4]
 
 [3] [7] [9] [4]
 
 [3, 7] [4, 9]
 
 [3, 4, 7, 9]
 
 */


/*
 let input = [12, 3, 13, 111, 987, 71, 17, 22, 3, 89, 18, 22]
 
 ___________left__________  _________right_________
 [12, 3, 13, 111, 987, 71]  [17, 22, 3, 89, 18, 22]
 
 ____left___ _____right____
 [12, 3, 13] [111, 987, 71] [17, 22, 3] [89, 18, 22]
 
 _L__ __R____                 _L_  __R____
 [12] [3, 13] [111] [987, 71] [17] [22, 3]  [89] [18, 22]
 
      _L_ _R_
 [12] [3] [13] [111] [987] [71] [17] [22] [3]  [89] [18] [22]
 
 _L__ ___R___  __L__ ___R____    _L_  ___R__   _L_  ___R___
 [12] [3, 13]  [111] [71, 987]   [17] [3, 22]  [89] [18, 22]
 
 ____L______  ______R_______  ____L______  _____R______
 [3, 12, 13]  [71, 111, 987]  [3, 17, 22]  [18, 22, 89]
  
 __________L______________  ________R______________
 [3, 12, 13, 71, 111, 987]  [3, 17, 18, 22, 22, 89]
 
 
 [3, 3, 12, 13, 17, 18, 22, 22, 71, 89, 111, 987]
 */
