import Foundation

public struct Header {
  static let acceptEncoding: String = "gzip;q=1.0, compress;q=0.5"

  static var acceptLanguage: String {
    return Locale.preferredLanguages.prefix(6).enumerated().map { index, languageCode in
      let quality = 1.0 - (Double(index) * 0.1)
      return "\(languageCode);q=\(quality)"
      }.joined(separator: ", ")
  }

  static let userAgent: String = {
    var string = "Malibu"

    if let info = Bundle.main.infoDictionary {
      let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
      let bundle = info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
      let version = info["CFBundleShortVersionString"] as? String ?? "Unknown"
      let build = info[kCFBundleVersionKey as String] as? String ?? "Unknown"

      string = "\(executable)/\(version) (\(bundle); build:\(build); \(Utils.osInfo)) \(Utils.frameworkInfo)"
    }

    return string
  }()

  public static let defaultHeaders: [String: String] = {
    return [
      "Accept-Encoding": acceptEncoding,
      "Accept-Language": acceptLanguage,
      "User-Agent": userAgent
    ]
  }()

  static func authentication(username: String, password: String) -> String? {
    let credentials = "\(username):\(password)"

    guard let credentialsData = credentials.data(using: String.Encoding.utf8) else {
      return nil
    }

    let base64Credentials = credentialsData.base64EncodedString(options: [])

    return "Basic \(base64Credentials)"
  }
}
