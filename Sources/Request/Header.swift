import Foundation

struct Header {
  
  static let acceptEncoding: String = "gzip;q=1.0, compress;q=0.5"
  
  static let defaultHeaders: [String: String] = {
    return [
      "Accept-Encoding": acceptEncoding,
      "User-Agent": userAgent
    ]
  }()
  
  static var acceptLanguage: String {
    return NSLocale.preferredLanguages().prefix(6).enumerate().map { index, languageCode in
      let quality = 1.0 - (Double(index) * 0.1)
      return "\(languageCode);q=\(quality)"
      }.joinWithSeparator(", ")
  }
  
  static let userAgent: String = {
    var string = "Malibu"
    
    if let info = NSBundle.mainBundle().infoDictionary {
      let executable: AnyObject = info[kCFBundleExecutableKey as String] ?? "Unknown"
      let bundle: AnyObject = info[kCFBundleIdentifierKey as String] ?? "Unknown"
      let version: AnyObject = info[kCFBundleVersionKey as String] ?? "Unknown"
      let os: AnyObject = NSProcessInfo.processInfo().operatingSystemVersionString ?? "Unknown"
      var mutableUserAgent = NSMutableString(
        string: "\(executable)/\(bundle) (\(version); OS \(os))") as CFMutableString
      let transform = NSString(string: "Any-Latin; Latin-ASCII; [:^ASCII:] Remove") as CFString
      
      if CFStringTransform(mutableUserAgent, UnsafeMutablePointer<CFRange>(nil), transform, false) {
        string = mutableUserAgent as String
      }
    }
    
    return string
  }()
  
  static func authentication(username: String, password: String) -> String? {
    let credentials = "\(username):\(password)"
    
    guard let credentialsData = credentials.dataUsingEncoding(NSUTF8StringEncoding) else {
      return nil
    }
    
    let base64Credentials = credentialsData.base64EncodedStringWithOptions([])
    
    return "Basic \(base64Credentials)"
  }
}
