import Foundation

public enum SessionConfiguration {
  case `default`
  case ephemeral
  case background
  case custom(URLSessionConfiguration)

  var value: URLSessionConfiguration {
    var value: URLSessionConfiguration

    switch self {
    case .default:
      value = URLSessionConfiguration.default
    case .ephemeral:
      value = URLSessionConfiguration.ephemeral
    case .background:
      value =  URLSessionConfiguration.background(
        withIdentifier: "MalibuBackgroundConfiguration")
    case .custom(let sessionConfiguration):
      value = sessionConfiguration
    }

    value.httpAdditionalHeaders = Header.defaultHeaders

    return value
  }
}
