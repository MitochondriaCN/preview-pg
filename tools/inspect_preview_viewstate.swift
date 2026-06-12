import Foundation

let plistURL = URL(fileURLWithPath: "/Users/xianliticn/Library/Containers/com.apple.Preview/Data/Library/Preferences/com.apple.Preview.ViewState.plist")
let data = try Data(contentsOf: plistURL)
let root = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: Any]

for targetKey in ["547C287B-E7A5-4636-A2A3-B1BAFA085F47.7750104", "547C287B-E7A5-4636-A2A3-B1BAFA085F47.7750774"] {
    print("=== \(targetKey) ===")
    guard let entry = root[targetKey] as? [String: Any], let nested = entry["Data"] as? Data else {
        print("missing")
        continue
    }
    let obj = try PropertyListSerialization.propertyList(from: nested, options: [], format: nil)
    print(obj)
}
