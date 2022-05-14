import UIKit

protocol NestedDatasource {
    
}

class UsingNestedDatasource: NestedDatasource {
    
}

class NestedView: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


//MARK: - Case 1
enum SpecialColor: Int {
    case red
    case blue
    case green
}

enum SpecialSize: Int {
    case small
    case normal
    case Big
}

protocol CarNoiseGenericProtocol: AnyObject {
    associatedtype Car
    associatedtype SomeSpecial
    func makeSound(car: Car, special: SomeSpecial)
}

class UsingCarNoiseGenericProtocol<Special>: CarNoiseGenericProtocol where Special: RawRepresentable {
    func makeSound(car: Car<Special>, special: Special) { }
}

class Car<Special: RawRepresentable> {
    var soundDelegate: UsingCarNoiseGenericProtocol<Special>?
    var name: String = "Volve"
    
    func makeNoise(s: Special) {
        soundDelegate?.makeSound(car: self, special: s)
    }
}

class ColorRobot: UsingCarNoiseGenericProtocol<SpecialColor> {
    override func makeSound(car: Car, special: SpecialColor) {
        debugPrint("\(car.name): AAAA \(special)")
    }
}

class SizeRobot: UsingCarNoiseGenericProtocol<SpecialSize> {
    override func makeSound(car: Car, special: SpecialSize) {
        debugPrint("\(car.name): AAAA \(special)")
    }
}

let car = Car<SpecialColor>()
let colorR = ColorRobot()
car.soundDelegate = colorR
car.makeNoise(s: .red)

let car2 = Car<SpecialSize>()
let sizeR = SizeRobot()
car2.soundDelegate = sizeR
car2.makeNoise(s: .Big)


//MARK: - 呼叫時才確認型別
protocol PeopleFoodGenericProtocol: AnyObject {
    associatedtype Food
    func eat(f: Food)
}

protocol Fruit {
    var name: String { get }
}

class Banana: Fruit {
    var name: String = "Banana"
}

class Apple: Fruit {
    var name: String = "Apple"
}

class People<F: Fruit>: PeopleFoodGenericProtocol {
    func eat(f: F) {
        debugPrint(f.name)
    }
}

let peopleA = People<Banana>()
peopleA.eat(f: Banana())
let peopleB = People<Apple>()
peopleB.eat(f: Apple())


//MARK: -  使用generic protocol as delegate情境1

enum RainType: Int {
    case noRain
    case light
    case normal
    case heavy
}

enum AnimalType: String {
    case cat
    case dog
    case bird
    case zebra
}

enum MusicType: String {
    case piano
    case violent
}

class GenericClass<T: RawRepresentable> {
    func classShowType(view: MyClass<T>, type: T?) {}
}

class MyClass<T: RawRepresentable> {
    
    weak var delegate: GenericClass<T>?

    func showType(for rowValue: T.RawValue) {
        delegate?.classShowType(view: self, type: T.init(rawValue: rowValue))
    }
}

class RainClass: GenericClass<RainType> {
    override func classShowType(view: MyClass<RainType>, type: RainType?) {
        debugPrint(type)
    }
}

class AnimalClass: GenericClass<AnimalType> {
    override func classShowType(view: MyClass<AnimalType>, type: AnimalType?) {
        debugPrint(type)
    }
}

class MusicClass: UIView {
    
}

extension MusicClass: GenericClass<MusicType> {
    
}

let rain = RainClass()
let myClass = MyClass<RainType>()
myClass.delegate = rain
myClass.showType(for: 1)

let animal = AnimalClass()
let myClassAnimal = MyClass<AnimalType>()
myClassAnimal.delegate = animal
myClassAnimal.showType(for: "cat")
