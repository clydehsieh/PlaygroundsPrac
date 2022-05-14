import UIKit
import Combine

class ViewModel {
    var filterString: String = "" {
        didSet {
            debugPrint("didSet filterString \(filterString)")
        }
    }
}

let textFiled = UITextField()
let vm = ViewModel()

let sub = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: textFiled)
    .map( { ($0.object as! UITextField).text! })
    .filter({ $0.unicodeScalars.allSatisfy({ CharacterSet.alphanumerics.contains($0) }) })
    .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
    .receive(on: RunLoop.main)
    .assign(to: \ViewModel.filterString, on: vm)

textFiled.text = "123"


//MARK: - Subscribers
func sinkSubscribers(prefix: String) -> Subscribers.Sink<String, Never> {
    Subscribers.Sink<String, Never> {
        print("\(prefix) completed: \($0)")
    } receiveValue: {
        print("\(prefix) received value: \($0)")
    }
}

func assignSubscribers() -> Subscribers.Assign<ViewModel, String> {
    Subscribers.Assign(object: vm, keyPath: \ViewModel.filterString)
}

func setupSubscrib(prefix: String, publisher: AnyPublisher<String, Never>) {
    let futureSinkSub = sinkSubscribers(prefix: prefix)
    let futureAssignSub = assignSubscribers()

    publisher.subscribe(futureSinkSub)
    publisher.subscribe(futureAssignSub)
    
    publisher.sink {
        print("other \(prefix) completed: \($0)")
    } receiveValue: {
        print("other \(prefix) received value: \($0)")
    }
}


//MARK: - Convenience Publisher
//MARK: Future
let futurePubisher = Future<String, Never> { promise in
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        promise(.success("Future success"))
    }
}.eraseToAnyPublisher()
//setupSubscrib(prefix: "futrue", publisher: futurePubisher)

//MARK: - Just
let justPubliser = Just.init("Just once").eraseToAnyPublisher()
//setupSubscrib(prefix: "Just", publisher: justPubliser)

//MARK: - Deferred
let deferredPublisher = Deferred {
    Future<String, Never> { promise in
        promise(.success("Deferred success"))
    }
}.eraseToAnyPublisher()
//setupSubscrib(prefix: "Deferred", publisher: deferredPublisher)

//MARK: Empty
let emptyS = Empty<String, Never>().eraseToAnyPublisher()
setupSubscrib(prefix: "empty", publisher: emptyS)
