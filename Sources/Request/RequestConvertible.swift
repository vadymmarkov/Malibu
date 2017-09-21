// MARK: - RequestConvertible

public protocol RequestConvertible {
  static var baseUrl: URLStringConvertible? { get }
  static var headers: [String: String] { get }
  var request: Request { get }
}

// MARK: - Defaults

struct AnyEndpoint: RequestConvertible {
  static let baseUrl: URLStringConvertible? = nil
  static let headers: [String: String] = [:]
  public let request: Request
}
