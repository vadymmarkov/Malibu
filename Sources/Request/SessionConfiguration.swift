import Foundation

public enum SessionConfiguration {
  case Default, Ephemeral, Background, Custom(NSURLSessionConfiguration)

  var value: NSURLSessionConfiguration {
    var value: NSURLSessionConfiguration

    switch self {
    case .Default:
      value = NSURLSessionConfiguration.defaultSessionConfiguration()
    case .Ephemeral:
      value = NSURLSessionConfiguration.ephemeralSessionConfiguration()
    case .Background:
      value =  NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(
        "MalibuBackgroundConfiguration")
    case .Custom(let sessionConfiguration):
      value = sessionConfiguration
    }

    value.HTTPAdditionalHeaders = Header.defaultHeaders

    return value
  }
}
