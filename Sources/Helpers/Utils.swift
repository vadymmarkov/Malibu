import Foundation

public struct Utils {

  // MARK: - Storage

  public static let documentDirectory =  NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
    .UserDomainMask, true).first!

  public static var storageRootDirectory: String = {
    let name = NSProcessInfo.processInfo().environment["XCInjectBundle"] != nil
      ? "MalibuTests"
      : "Malibu"

    let directory = "\(documentDirectory)/\(name)"

    do {
      try NSFileManager.defaultManager().createDirectoryAtPath(directory,
        withIntermediateDirectories: true,
        attributes: nil)
    } catch {
      NSLog("Malibu: Error in creation of local storage directory at path: \(directory)")
    }

    return directory
  }()

  public static func filePath(name: String) -> String {
    return "\(Utils.storageRootDirectory)/\(name)"
  }
}
