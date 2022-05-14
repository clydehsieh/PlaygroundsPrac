import UIKit

class Solution {
    func lengthOfLongestSubstringClyde(_ s: String) -> Int {
        guard s.count > 1 else { return s.count }
        
        var head = 0
        var max = 0
        
        for (index, c) in s.enumerated() {
            if index == 0 {
                continue
            }
            
            func subString() -> Substring {
                let start = s.index(s.startIndex, offsetBy: head)
                let end = s.index(s.startIndex, offsetBy: index)
                let range = start..<end
                return s[range]
            }
            
            let sub = subString()
            
            if sub.contains(c) {
                max = Swift.max(max, sub.count)
                
                while subString().contains(c) {
                    head += 1
                }
            } else {
                if index == s.count - 1 {
                    max = Swift.max(max, sub.count + 1)
                }
            }
        }
        return max
    }
    
    func lengthOfLongestSubstring(_ s: String) -> Int {
        guard !s.isEmpty else { return 0 }
            
            var length = 0
            var substring = [Character]()
            for c in s {
                if substring.contains(c), let index = substring.firstIndex(of: c) {
                    length = max(length, substring.count)
                    substring.removeSubrange(0...index)
                }
                substring.append(c)
            }
            
            return max(length, substring.count)
    }
}

let s = Solution()
s.lengthOfLongestSubstring("au")
s.lengthOfLongestSubstring("pwwke")
s.lengthOfLongestSubstring("abcabc")
s.lengthOfLongestSubstring("BBBBBB")
s.lengthOfLongestSubstring("aab")
s.lengthOfLongestSubstring("ckilbkd")
s.lengthOfLongestSubstring("nfpdmpi")
