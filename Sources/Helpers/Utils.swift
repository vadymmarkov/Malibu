import Foundation

struct Utils {

  // MARK: - Storage

  static let documentDirectory =  NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
    .UserDomainMask, true).first!

  static var storageDirectory: String = {
    let directory = "\(documentDirectory)/Malibu"

    do {
      try NSFileManager.defaultManager().createDirectoryAtPath(directory,
        withIntermediateDirectories: true,
        attributes: nil)
    } catch {
      NSLog("Malibu: Error in creation of local storage directory at path: \(directory)")
    }

    return directory
  }()

  static func filePath(name: String) -> String {
    return "\(Utils.storageDirectory)/\(name)"
  }
}
