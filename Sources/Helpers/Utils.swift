import Foundation

struct Utils {

  // MARK: - Storage

  static let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
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

  // MARK: - OS

  static var osName: String {
    #if os(iOS)
      return "iOS"
    #elseif os(tvOS)
      return "tvOS"
    #elseif os(watchOS)
      return "watchOS"
    #elseif os(OSX)
      return "macOS"
    #else
      return "Unknown"
    #endif
  }

  static var osInfo: String {
    let version = NSProcessInfo.processInfo().operatingSystemVersion
    return "\(osName) \(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
  }
}
