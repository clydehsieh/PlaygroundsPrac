import UIKit
import Darwin

open class Person {
    private var firstName: String
    private var lastName: String
    
    var name: String {
        return firstName + " " + lastName
    }
    
    public init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
    
    public func update(firstName: String, lastName: String, delay: TimeInterval) {
        randomDelay(min: delay, random: 0.2, content: firstName)
        self.firstName = firstName
        randomDelay(min: delay, random: 1.0, content: lastName)
        self.lastName = lastName
    }
    
    func randomDelay(min: TimeInterval, random: TimeInterval, content: String?) {
        let delay = TimeInterval.random(in: 0..<random) + min
        let second: Double = 1000000
        debugPrint("sleep: \(delay) content\(content ?? "")")
        usleep(useconds_t(delay * second))
    }
}

class ThreadSafePerson: Person {
    let isolatedQueue = DispatchQueue(label: "com.clyde.isolatedQueue", attributes: .concurrent)

    override func update(firstName: String, lastName: String, delay: TimeInterval) {
        isolatedQueue.async(flags: .barrier) {
            super.update(firstName: firstName, lastName: lastName, delay: delay)
        }
    }
    
    override var name: String {
        return isolatedQueue.sync {
            super.name
        }
    }
}

let workQueue = DispatchQueue(label: "com.clyde.work", attributes: .concurrent)
let nameChangeGroup = DispatchGroup()

let person = Person(firstName: "111", lastName: "1Wu")
let safePerson = ThreadSafePerson(firstName: "111", lastName: "1Wu")
let nameArray = [("2First", "2Last"),
                 ("3First", "3Last"),
                 ("4First", "4Last"),
                 ("5First", "5Last"),
                 ("6First", "6Last")]


func updatePersion() {
    for (idx, name) in nameArray.enumerated() {
        workQueue.async(group: nameChangeGroup) {
            let secondValue: Double = Double((idx + 1) / 100)
            person.update(firstName: name.0, lastName: name.1, delay: secondValue)
            debugPrint("Current: \(person.name)")
        }
    }
    
    nameChangeGroup.notify(queue: .global()) {
        debugPrint("final: \(person.name)")
        updateSafePerson()
    }
}

func updateSafePerson() {
    for (idx, name) in nameArray.enumerated() {
        workQueue.async(group: nameChangeGroup) {
            let secondValue: Double = Double((idx + 1) / 100)
            safePerson.update(firstName: name.0, lastName: name.1, delay: secondValue)
            debugPrint("Current: sPerson \(safePerson.name)")
        }
    }
    
    nameChangeGroup.notify(queue: .global()) {
        debugPrint("final: sPerson \(safePerson.name)")
    }
}

updatePersion()
