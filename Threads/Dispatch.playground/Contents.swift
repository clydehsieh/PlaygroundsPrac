import UIKit


//MARK: -
// Reference: https://manasaprema04.medium.com/multithreading-in-ios-part-2-3-fe0116ffee5

// Dispatch groupY

class DispatchGroupTest {
    let group = DispatchGroup()
    
    func runWait() {
        
        for i in 0...3 {
            group.enter()
            DispatchQueue.global().async { [self]
                sleep(arc4random() % 4)
                print("long tast done \(i)")
                self.group.leave()
            }
        }
        
        group.wait()
        print("1..3 done, and start 4...6")
        
        for i in 4...6 {
            group.enter()
            DispatchQueue.global().async { [self]
                sleep(arc4random() % 4)
                print("long tast done \(i)")
                self.group.leave()
            }
        }
        
        group.wait()
        print("4...6 done")
    }
    
    func runNotify() {
        for i in 0...3 {
            group.enter()
            DispatchQueue.global().async { [self]
                sleep(arc4random() % 4)
                print("long tast done \(i)")
                self.group.leave()
            }
        }
        
        group.notify(queue: .global()) {
            print("all done")
        }
    }
}

let dispatchGroupTest = DispatchGroupTest()
dispatchGroupTest.runNotify()
