import UIKit

// Reference: https://medium.com/geekculture/threads-in-ios-gcd-nsoperation-part-1-64e460c0bdea

// Memory
let current = Thread.current
debugPrint("current thread", current, current.stackSize) // 524288 aka 524 kb aka 0.5MB

let t = Thread()
t.name = "secondary"
debugPrint("second thread with default size", t, t.stackSize) // 524288

let t1 = Thread()
t1.name = "secondary1"
t1.stackSize = 4096 * 512 //  mutiple of 4kb, minimum is 16kb
debugPrint("second thread", t1, t1.stackSize) // 2097152

//
class ThreadTest {
    func createThreadByDetachNew() {
        Thread.detachNewThreadSelector(#selector(printStyle1), toTarget: self, with: nil)
    }
    
    func createThread() {
        let thread = Thread(target: self, selector: #selector(printStyle2), object: nil)
        thread.start()
    }
    
    @objc func printStyle1() {
        debugPrint("Thread loop running")
    }
    
    @objc func printStyle2() {
        debugPrint("Thread loop running printStyle2")
    }
}

let test = ThreadTest()
test.createThreadByDetachNew()
test.createThread()
