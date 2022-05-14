
protocol FullName {
    var fullName: String { get } // gettable
}

struct Detective: FullName {
    var fullName: String // variant is gettable and settable, confrom to the protocol!
}

let hercule = Detective(fullName: "Hercule Poirot")
print(hercule.fullName)

var bond = Detective(fullName: "bond")
print(bond.fullName)
bond.fullName = "James Bond"
print(bond.fullName)

//
struct DetectiveComputable: FullName {
    fileprivate var name: String
    var fullName: String {
       return name
    }
}

var batman = DetectiveComputable(name: "batman")
print(batman.fullName)
//batman.fullName = "batman rich" // error: get-only!

//
struct DetectivePrivateSet: FullName {
    private(set) var fullName: String
    
    mutating func rename(_ name: String) {
        fullName = name
    }
}

var holmes = DetectivePrivateSet(fullName: "holmes")
print(holmes.fullName)
//holmes.fullName = "Sherlock Holmes" // error: Cannot assign to property: 'fullName' setter is inaccessible
holmes.rename("Sherlock Holmes")
print(holmes.fullName)


struct DetectiveComputableGetAndSet: FullName {
    fileprivate var name: String
    var fullName: String {
        get {
            return name
        }
        set {
            name = newValue
        }
    }
}
var Payne = DetectiveComputableGetAndSet(name: "Payne")
print(Payne.fullName) // returns "Payne"
Payne.fullName = "Max Payne"
print(Payne.fullName) // returns "Max Payne"
