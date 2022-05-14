import UIKit

class StringMapper {
    
    enum StringMapperError: Error {
        case inputTooShort
        case inputTooLong
    }
    
    let prefix: String
    required init(prefix: String) {
        self.prefix = prefix
    }
    
    func print(with origin: String) throws -> String {
        if origin.isEmpty {
            throw StringMapperError.inputTooShort
        }
        
        if origin.count > 3 {
            throw StringMapperError.inputTooLong
        }
        
        return (prefix + origin)
    }
}

extension StringMapper.StringMapperError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .inputTooShort:
            return NSLocalizedString("A user-friendly description of the error.", comment: "inputTooShort")
        case .inputTooLong:
            return NSLocalizedString("A user-friendly description of the error.", comment: "inputTooLong")
        }
    }
}

class Book {
    var StringMapperClass = StringMapper.self
    
    func showContent(content: String) {
        let mapper = StringMapperClass.init(prefix: "Cool")
        do {
            let content = try mapper.print(with: content)
            debugPrint(content)
        } catch StringMapper.StringMapperError.inputTooShort {
            debugPrint("too short")
        } catch let e {
            e.localizedDescription
        }
    }
}

class StubStringMapper: StringMapper {
    override func print(with origin: String) throws -> String {
        if origin.count == 1 {
            throw StringMapperError.inputTooShort
        }
        
        if origin.count > 4 {
            throw StringMapperError.inputTooLong
        }
        
        return "test" + origin
    }
}

let bookObj = Book()
bookObj.StringMapperClass = StubStringMapper.self

bookObj.showContent(content: "")
bookObj.showContent(content: "1")
bookObj.showContent(content: "123")
bookObj.showContent(content: "124")
bookObj.showContent(content: "super cool")


//MARK: - Custom Error
enum CompareError: Error {
    case rightIsGreater
    case unknow
}

extension CompareError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .rightIsGreater:
            return "rightIsGreater"
        default:
            return "unknow"
        }
    }
}

func checkGreater(left: CGFloat, right: CGFloat) throws -> CGFloat {
    if right > left {
        throw CompareError.rightIsGreater
    }
    return left
}

func startCompare() {
//    let result: Result<CGFloat, Error>
    
    let result = Result {
        try checkGreater(left: 1, right: 3)
    }
    
    switch result {
    case let .success(left):
        debugPrint("left \(left)")
    case let .failure(error):
        debugPrint(error.localizedDescription)
    }
    
    let result2 = Result {
        try checkGreater(left: 3, right: 1)
    }
    
    switch result2 {
    case let .success(left):
        debugPrint("left \(left)")
    case let .failure(error):
        break
    }
}
startCompare()


//MARK: - Protocol
protocol CellConfigurable {
    func configure(_ datasource: MeetupCellDataSoruce, _ delegate: TapSwitchDelegate?)
}

protocol MeetupCellDataSoruce {
    var title: String { get }
    var switchOn: Dynamic<Bool> { get }
}

protocol TapSwitchDelegate {
    func didTapSwitch()
}

class Dynamic<T> {
    var value: T {
        didSet {
            handler?(value)
        }
    }
    var handler: ((T)->Void)?
    
    init(value: T) {
        self.value = value
    }
    
    func bind(_ handler: @escaping ((T)->Void)) {
        self.handler = handler
    }
}

struct MeetupCellViewModel: MeetupCellDataSoruce {
    var title: String = "Hi"
    var switchOn: Dynamic<Bool> = .init(value: false)
}

extension MeetupCellViewModel: TapSwitchDelegate {
     func didTapSwitch() {
         switchOn.value.toggle()
    }
}

class MeetupCell: CellConfigurable {
    var cellTitle: String = ""
    var switchOn: Bool = false
    
    var delegate: TapSwitchDelegate?
    
    func configure(_ datasource: MeetupCellDataSoruce, _ delegate: TapSwitchDelegate?) {
        self.cellTitle = datasource.title
        self.switchOn  = datasource.switchOn.value
        
        datasource.switchOn.bind { isOn in
            self.switchOn = isOn
        }
        
        self.delegate = delegate
    }
    
    func makeChange() {
        self.delegate?.didTapSwitch()
    }
}


let viewModel = MeetupCellViewModel()
let cell = MeetupCell()
cell.configure(viewModel, viewModel)
viewModel.switchOn
cell.makeChange()
viewModel.switchOn.value
cell.switchOn
