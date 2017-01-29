public protocol Endpoint {

  static var baseUrl: URLStringConvertible { get }
  static var headers: [String: String] { get }
  static var sessionConfiguration: SessionConfiguration { get }

  var request: Request { get }
}

public extension Endpoint {

  static var sessionConfiguration: SessionConfiguration {
    return .default
  }
}

// MARK: - Defaults

struct AnyEndpoint: Endpoint {

  static let baseUrl: URLStringConvertible = ""
  static let headers: [String: String] = [:]
  static let sessionConfiguration: SessionConfiguration = SessionConfiguration.default

  public let request: Request
}
