import UIKit

 public class ListNode {
     public var val: Int
     public var next: ListNode?
     public init() { self.val = 0; self.next = nil; }
     public init(_ val: Int) { self.val = val; self.next = nil; }
     public init(_ val: Int, _ next: ListNode?) { self.val = val; self.next = next; }
 }

class Solution {
    func addTwoNumbers(_ l1: ListNode?, _ l2: ListNode?) -> ListNode? {
        var node: ListNode? = ListNode(0)
        let head = node
        
        var carry = 0
        
        var l1 = l1
        var l2 = l2
        
        while l1 != nil || l2 != nil || carry > 0 {
            let sum = (l1?.val ?? 0) + (l2?.val ?? 0 ) + carry
            let result = sum.quotientAndRemainder(dividingBy: 10)
            carry = result.quotient
            
            l1 = l1?.next
            l2 = l2?.next
            
            node?.next = ListNode(result.remainder)
            node = node?.next
        }

        return head?.next
    }
}
