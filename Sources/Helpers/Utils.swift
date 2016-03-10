import Foundation

public struct Utils {

  // MARK: - Storage

  public static let documentDirectory =  NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
    .UserDomainMask, true).first!

  public static func storagePath(path: String) -> String {
    return Utils.storageRootDirectory + path
  }

  public static var storageRootDirectory: String = {
    return NSProcessInfo.processInfo().environment["XCInjectBundle"] != nil
      ? "MalibuTests"
      : "Malibu"
  }()
}
