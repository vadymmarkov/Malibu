import Foundation

struct Utils {
  // MARK: - Storage

  static let documentDirectory = NSSearchPathForDirectoriesInDomains(
    .documentDirectory,
    .userDomainMask, true).first!

  static var storageDirectory: String = {
    let directory = "\(documentDirectory)/Malibu"

    do {
      try FileManager.default.createDirectory(atPath: directory,
        withIntermediateDirectories: true,
        attributes: nil)
    } catch {
      NSLog("Malibu: Error in creation of local storage directory at path: \(directory)")
    }

    return directory
  }()

  static func filePath(_ name: String) -> String {
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
    #elseif os(macOS)
      return "macOS"
    #else
      return "Unknown"
    #endif
  }

  static var osInfo: String {
    let version = ProcessInfo.processInfo.operatingSystemVersion
    return "\(osName) \(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
  }

  // MARK: - Framework

  static let frameworkInfo: String = {
    guard
      let info = Bundle(for: NetworkPromise.self).infoDictionary,
      let build = info["CFBundleShortVersionString"]
      else { return "Unknown" }

    return "Malibu/\(build)"
  }()
}
