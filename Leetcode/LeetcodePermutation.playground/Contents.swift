/*
 no. 46
 backtracing
 https://haogroot.com/2020/09/21/backtracking-leetcode/
 */

class Solution {
    func permute(_ nums: [Int]) -> [[Int]] {
        if nums.count == 1 {
            return [nums]
        }
        
        var result = [[Int]]()
        for index in 0..<nums.count {
            var copy = nums
            let first = copy.remove(at: index)
            let subPermute = self.permute(copy)
            
            for subPermuteNum in subPermute {
                result.append( [first] + subPermuteNum )
            }
        }
        
        return result
    }
}

/*
 
 
 */
class BestSolution {
    func permute(_ nums: [Int]) -> [[Int]] {
        var nums = nums
        var result = [[Int]]()
        permuteRecursive(&nums, 0, &result)
        return result
    }
    
    func permuteRecursive(_ nums: inout [Int], _ begin: Int, _ result: inout [[Int]] ) {
        if begin >= nums.count {
            result.append(nums)
            return
        }
        for i in begin..<nums.count {
            nums.swapAt(begin, i)
            permuteRecursive(&nums, begin+1, &result)
            nums.swapAt(begin, i)
            
        }
    }
}

let input = [1, 2, 3]
let s = BestSolution()
let output = s.permute(input)
