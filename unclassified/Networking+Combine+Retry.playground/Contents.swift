import UIKit
import Combine
import PlaygroundSupport

protocol ImageFetchable {
    func fetchAvatar(url: URL) -> AnyPublisher<UIImage, Error>
}

enum CustomError: Error {
    case notFound
    case retry
}

enum State: String {
    case initial = "Initial"
    case loading = "Loading"
    case loadedSuccessfully = "Success"
    case loadingFailed = "Failure"
}

class ImageFetchService: ImageFetchable {
    
    var retryCount = 0
    
    func fetchAvatar(url: URL) -> AnyPublisher<UIImage, Error> {
        return Deferred {
            Future { promise in
                DispatchQueue.global().async { [self] in
                    
                    guard self.retryCount > 1 else {
                        self.retryCount += 1
                        promise(.failure(CustomError.retry))
                        return
                    }
                    
                    self.retryCount = 0
                    
                    guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
                        promise(.failure(CustomError.notFound))
                        return
                    }
                    
                    promise(.success(image))
                }
            }
        }.eraseToAnyPublisher()
    }
}

protocol ViewModelProtocol {
    var state: PassthroughSubject<State, Never> { get }
    var updateImageSubject: PassthroughSubject<UIImage, Never> { get }
    func loadImage()
}

class ViewModel: ViewModelProtocol {
    var state: PassthroughSubject<State, Never> = .init()
    
    var imageFetchService: ImageFetchable
    
    var cancelables: Set<AnyCancellable> = .init()
    
    var updateImageSubject: PassthroughSubject<UIImage, Never> = .init()
    
    init(imageFetchService: ImageFetchable) {
        self.imageFetchService = imageFetchService
    }
    
    func loadImage() {
        let url = URL(string: "https://picsum.photos/1000")!
        
        self.imageFetchService.fetchAvatar(url: url)
            .handleEvents { [weak self] subscription in
                debugPrint("handleEvents \(subscription)")
                self?.state.send(.loading)
            } receiveOutput: { image in
                debugPrint("receiveOutput \(image)")
            } receiveCompletion: { completoin in
                debugPrint("receiveCompletion \(completoin)")
            } receiveCancel: {
                debugPrint("receiveCancel")
            } receiveRequest: { demand in
                debugPrint("receiveRequest \(demand)")
            }
            .receive(on: DispatchQueue.main)
            .retry(3)
            .replaceError(with: UIImage() )
            .sink { [weak self] completion in
                switch completion {
                case let .failure(error):
                    debugPrint("sink completion error \(error)")
                    self?.state.send(.loadingFailed)
                case .finished:
                    debugPrint("sink completion finished")
                }
            } receiveValue: { [weak self] image in
                self?.updateImageSubject.send(image)
                self?.state.send(.loadedSuccessfully)
            }
            .store(in: &cancelables)
    }
}

class ViewController: UIViewController {
    
    let vm: ViewModelProtocol
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    var cancellables: Set<AnyCancellable> = .init()
    
    init(vm: ViewModelProtocol) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        
        constructViewHeirarchy()
        activeConstraints()
        setupBinding()
        
        title = "Test"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        vm.loadImage()
    }
    
    private func constructViewHeirarchy() {
        view.addSubview(imageView)
    }
    
    private func activeConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupBinding() {
        vm.updateImageSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.imageView.image = image
            }
            .store(in: &cancellables)
        
        vm.state
            .receive(on: DispatchQueue.main)
            .map({ $0.rawValue })
            .sink { [weak self] title in
                self?.title = title
            }
            .store(in: &cancellables)
    }
}

let service = ImageFetchService()
let viewModel = ViewModel(imageFetchService: service)
let vc = ViewController(vm: viewModel)
let navi = UINavigationController(rootViewController: vc)
navi.preferredContentSize = CGSize(width: 375, height: 667)

PlaygroundPage.current.liveView = navi
