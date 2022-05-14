import UIKit

class AppVersion {
    var rawValue: String
    init(version: String) {
        self.rawValue = version
    }
    
    func compareVersion(_ version: AppVersion)  {
        let result = self.rawValue.compare(version.rawValue, options: .numeric)
        var middleWord = ""
        switch result {
        case .orderedSame:
            middleWord = "same"
        case .orderedAscending:
            middleWord = "smaller than"
        case .orderedDescending:
            middleWord = "greater than"
        }
        
        debugPrint("\(self.rawValue) is \(middleWord) \(version.rawValue)")
    }
}


let ver  = AppVersion(version: "4.5.2")
let ver2 = AppVersion(version: "4.5.1")
let ver3 = AppVersion(version: "4.5.1.9")
let ver4 = AppVersion(version: "4.5.2.1")
let ver5 = AppVersion(version: "4.4")
let ver6 = AppVersion(version: "4.5")
let ver7 = AppVersion(version: "4.6")

ver.compareVersion(ver2)
ver.compareVersion(ver3)
ver.compareVersion(ver4)
ver.compareVersion(ver5)
ver.compareVersion(ver6)
ver.compareVersion(ver7)
