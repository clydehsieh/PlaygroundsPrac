import UIKit
import Foundation

let nameOperation = BlockOperation()
nameOperation.addExecutionBlock {
    debugPrint("name 1")
}
nameOperation.addExecutionBlock {
    debugPrint("name 2")
}


let heightOperation = BlockOperation()
heightOperation.addExecutionBlock {
    debugPrint("height 1")
}
heightOperation.addExecutionBlock {
    debugPrint("height 2")
}


let queue = OperationQueue()
queue.qualityOfService = .utility
queue.addOperations([nameOperation, heightOperation], waitUntilFinished: false)
