// MARK: - Endpoint

public protocol Endpoint {

  static var baseUrl: URLStringConvertible { get }
  static var headers: [String: String] { get }

  var request: Request { get }
}

// MARK: - Defaults

struct AnyEndpoint: Endpoint {

  static let baseUrl: URLStringConvertible = ""
  static let headers: [String: String] = [:]
  public let request: Request
}
