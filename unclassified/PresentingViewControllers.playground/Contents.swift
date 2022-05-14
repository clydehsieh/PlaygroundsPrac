import UIKit
import PlaygroundSupport

class Container {
    let isolatedQueue = DispatchQueue.init(label: "com.clyde.test", attributes: .concurrent)
    
    private var content = [UIViewController]()
    
    func add(_ element: UIViewController) {
        isolatedQueue.async(flags: .barrier) { [self]
            self.content.append(element)
        }
    }
    
    var vcs:  [UIViewController] {
        isolatedQueue.sync {
            content
        }
    }
    
    func printRelations() {
        for vc in vcs {
            let ingTag = vc.presentingViewController != nil ? "\(vc.presentingViewController!.view.tag)" : "nil"
            let edTag  = vc.presentedViewController != nil ?  "\(vc.presentedViewController!.view.tag)"  : "nil"
            debugPrint("vc\(vc.view.tag) ing: \(ingTag) ed: \(edTag)")
        }
        cleanAll()
    }
    
    func cleanAll() {
        isolatedQueue.async(flags: .barrier) { [self]
            self.content.removeAll()
        }
    }
}

extension UIViewController {
    
    func findTheFirstPresentingViewController() -> UIViewController {
        var vc = self
        
        while (vc.presentingViewController != nil) {
            vc = vc.presentingViewController!
        }
        
        debugPrint("findTheFirstPresentingViewController vc\(vc.view.tag)")
        return vc
    }
}

class CustomViewController: UIViewController {
    
    var nextPresent: UIViewController?
    var nextPush: UIViewController?
    weak var container: Container?
    var completion: (()->Void)?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let vc = nextPresent {
            debugPrint("vc\(self.view.tag) present \(vc.view.tag)")
            self.present(vc, animated: false, completion: nil)
            nextPresent = nil
        }
        
        if let vc = nextPush, let navi = navigationController {
            debugPrint("vc\(self.view.tag) navi push \(vc.view.tag)")
            navi.pushViewController(vc, animated: true)
            nextPush = nil
        }
        
        if let container = self.container {
            debugPrint("vc\(self.view.tag) isLast")
            debugPrint("→→→showPresentingAndPresented →→→")
            
            container.printRelations()
        }
        
        completion?()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        debugPrint("viewDidDisappear vc\(self.view.tag)")
    }
    
    deinit {
        debugPrint("deinit vc\(self.view.tag)")
    }
}
 
let container = Container()

func createViewController(tag: Int) -> CustomViewController {
    let vc = CustomViewController()
    vc.view.tag = tag
    container.add(vc)
    return vc
}

//MARK: -

func casePresentSerialAndDismissLast() {
    debugPrint(" ↓↓↓↓ ")
    debugPrint(" casePresentSerialAndDismissLast ")
    // 0 - 1 - 2
    //    "vc0 ing: nil ed: 1"
    //    "vc1 ing: 0 ed: 2"
    //    "vc2 ing: 1 ed: nil"
    let vc0 = createViewController(tag: 0)
    let vc1 = createViewController(tag: 1)
    let vc2 = createViewController(tag: 2)
    
    vc0.nextPresent = vc1
    vc1.nextPresent = vc2
    vc2.container = container
    vc2.completion = { [weak vc2] in
        vc2?.dismiss(animated: false, completion: nil)
    }
    PlaygroundPage.current.liveView = vc0
}

func casePresentSerialAndDismissFirst() {
    debugPrint(" ↓↓↓↓ ")
    debugPrint(" casePresentSerialAndDismissLast ")
    // 0 - 1 - 2
    //    "vc0 ing: nil ed: 1"
    //    "vc1 ing: 0 ed: 2"
    //    "vc2 ing: 1 ed: nil"
    let vc0 = createViewController(tag: 0)
    let vc1 = createViewController(tag: 1)
    let vc2 = createViewController(tag: 2)
    
    vc0.nextPresent = vc1
    vc1.nextPresent = vc2
    vc2.container = container
    vc2.completion = { [weak vc0] in
        vc0?.dismiss(animated: false, completion: nil)
    }
    PlaygroundPage.current.liveView = vc0
}

var naviHolder: UINavigationController? = nil

func casePushSerialAndPopToRootViewController() {
    debugPrint(" ↓↓↓↓ ")
    debugPrint(" casePushSerialAndPopToRootViewController ")
    // [0, 1, 2]
//    "vc0 ing: nil ed: nil"
//    "vc1 ing: nil ed: nil"
//    "vc2 ing: nil ed: nil"
    let vc0 = createViewController(tag: 0)
    let vc1 = createViewController(tag: 1)
    let vc2 = createViewController(tag: 2)
    
    let navi = UINavigationController.init(rootViewController: vc0)
    naviHolder = navi
    navi.view.tag = 100
    vc0.nextPush = vc1
    vc1.nextPush = vc2
    vc2.container = container
    vc2.completion = { [weak navi] in
        navi?.popToRootViewController(animated: false)
        // if call navi?.dismiss(animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
        // nothing happen
    }
    PlaygroundPage.current.liveView = navi.view
}

func casePushThenPresentTypeA() {
    debugPrint(" ↓↓↓↓ ")
    debugPrint(" casePushThenPresentTypeA ")
    // [0] - 1 - 2
//    "vc0 ing: nil ed: 1"
//    "vc1 ing: 100 ed: 2"
//    "vc2 ing: 1 ed: nil"
    let vc0 = createViewController(tag: 0)
    let vc1 = createViewController(tag: 1)
    let vc2 = createViewController(tag: 2)
    
    let navi = UINavigationController.init(rootViewController: vc0)
    naviHolder = navi
    navi.view.tag = 100
    vc0.nextPresent = vc1
    vc1.nextPresent = vc2
    vc2.container = container
    vc2.completion = { [weak vc2] in
        vc2?.findTheFirstPresentingViewController().dismiss(animated: false, completion: nil)
    }
    PlaygroundPage.current.liveView = navi.view
}

func casePushThenPresentTypeB() {
    debugPrint(" ↓↓↓↓ ")
    debugPrint(" casePushThenPresentTypeB ")
    // [0, 1] - 2 - [3, 4]
//    "vc0 ing: nil ed: 2"
//    "vc1 ing: nil ed: 2"
//    "vc2 ing: 100 ed: 200"
//    "vc3 ing: 2 ed: nil"
//    "vc4 ing: 2 ed: nil"
    let vc0 = createViewController(tag: 0)
    let vc1 = createViewController(tag: 1)
    let vc2 = createViewController(tag: 2)
    let vc3 = createViewController(tag: 3)
    let vc4 = createViewController(tag: 4)
    vc0.view.backgroundColor = .blue
    vc1.view.backgroundColor = .red
    vc2.view.backgroundColor = .yellow
    
    let navi = UINavigationController.init(rootViewController: vc0)
    naviHolder = navi
    navi.view.tag = 100
    
    let navi2 = UINavigationController.init(rootViewController: vc3)
    navi2.view.tag = 200
    
    vc0.nextPush = vc1
    vc1.nextPresent = vc2
    vc2.nextPresent = navi2
    vc3.nextPush = vc4
    vc4.container = container
    vc4.completion = { [weak navi] in
        /*
         navi1, vc0, vc1
         呼叫 dismiss(animated: false, completion: nil)
         
         will back to vc1, not the root vc0
            [0, 1] - 2 - [3, 4]
         -> [0, 1]
         
         */
        
        /*
         navi1
         呼叫 popToRootViewController(animated: false)

            [0, 1] - 2 - [3, 4]
         -> [0]
         
         */
        
        /*
         navi2, vc2, vc3, vc4,
         呼叫 dismiss(animated: false, completion: nil)

            [0, 1] - 2 - [3, 4]
         -> [0, 1] - 2
         
         */
        
        /*
         navi1,
         呼叫 dismiss(animated: false, completion: nil)
         在呼叫 popToRootViewController(animated: false)
         
         will back to vc1, not the root vc0
            [0, 1] - 2 - [3, 4]
         -> [0]
         
         */
        
        /*
         結論：
         呼叫 dismiss(animated: false, completion: nil),
         如果有子節點(presentedViewController), 則移除後面所有子節點, 自己留著
         如果沒有子節點, 則自己移除
         */
        
        navi?.dismiss(animated: false, completion: {
            navi?.popToRootViewController(animated: false)
        })
    }
    
    PlaygroundPage.current.liveView = navi.view
}

func casePushThenPresentTypeC() {
    debugPrint(" ↓↓↓↓ ")
    debugPrint(" casePushThenPresentTypeC ")
    // [0, 1] - 2 - [3, 4, 5] - 6 - 7
//    "vc0 ing: nil ed: 2"
//    "vc1 ing: nil ed: 2"
//    "vc2 ing: 100 ed: 200"
//    "vc3 ing: 2 ed: 6"
//    "vc4 ing: 2 ed: 6"
//    "vc5 ing: 2 ed: 6"
//    "vc6 ing: 200 ed: 7"
//    "vc7 ing: 6 ed: nil"
    let vc0 = createViewController(tag: 0)
    let vc1 = createViewController(tag: 1)
    let vc2 = createViewController(tag: 2)
    let vc3 = createViewController(tag: 3)
    let vc4 = createViewController(tag: 4)
    let vc5 = createViewController(tag: 5)
    let vc6 = createViewController(tag: 6)
    let vc7 = createViewController(tag: 7)
    let navi = UINavigationController.init(rootViewController: vc0)
    naviHolder = navi
    navi.view.tag = 100
    
    let navi2 = UINavigationController.init(rootViewController: vc3)
    navi2.view.tag = 200
    
    vc0.nextPush = vc1
    vc1.nextPresent = vc2
    vc2.nextPresent = navi2
    vc3.nextPush = vc4
    vc4.nextPush = vc5
    vc5.nextPresent = vc6
    vc6.nextPresent = vc7
    vc7.container = container
    vc7.completion = { [ weak vc3] in
        /*
         back to vc 5
            [0, 1] - 2 - [3, 4, 5] - 6 - 7
         -> [0, 1] - 2 - [3, 4, 5]
         */
        vc3?.dismiss(animated: false, completion: nil)
    }
    
    PlaygroundPage.current.liveView = navi.view
}

func casePushThenPresentTypeD() {
    debugPrint(" ↓↓↓↓ ")
    debugPrint(" casePushThenPresentTypeD ")
    // [0, 1] - 2 - [3, 4, 5] - 6 - 7
//    "vc0 ing: nil ed: 2"
//    "vc1 ing: nil ed: 2"
//    "vc2 ing: 100 ed: 200"
//    "vc3 ing: 2 ed: 6"
//    "vc4 ing: 2 ed: 6"
//    "vc5 ing: 2 ed: 6"
//    "vc6 ing: 200 ed: 7"
//    "vc7 ing: 6 ed: nil"
    let vc0 = createViewController(tag: 0)
    let vc1 = createViewController(tag: 1)
    let vc2 = createViewController(tag: 2)
    let vc3 = createViewController(tag: 3)
    let vc4 = createViewController(tag: 4)
    let vc5 = createViewController(tag: 5)
    let vc6 = createViewController(tag: 6)
    let vc7 = createViewController(tag: 7)
    let navi = UINavigationController.init(rootViewController: vc0)
    naviHolder = navi
    navi.view.tag = 100
    
    let navi2 = UINavigationController.init(rootViewController: vc3)
    navi2.view.tag = 200
    
    vc0.nextPush = vc1
    vc1.nextPresent = vc2
    vc2.nextPresent = navi2
    vc3.nextPush = vc4
    vc4.nextPush = vc5
    vc5.nextPresent = vc6
    vc6.completion = { [ weak navi2, weak vc7] in
        guard let strongVC7 = vc7 else { return }
        navi2?.present(strongVC7, animated: true, completion: {
            
        })
    }
    vc7.container = container
    
    
    PlaygroundPage.current.liveView = navi.view
}
casePushThenPresentTypeD()
