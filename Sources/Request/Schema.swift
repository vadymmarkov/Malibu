public protocol Schema {

  associatedtype EndpointType: Endpoint

  var baseUrl: URLStringConvertible { get }
  var headers: [String: String] { get }
  var sessionConfiguration: SessionConfiguration { get }
}

public protocol Endpoint {

  var request: Request { get }
}

// MARK: - Defaults

extension Request: Endpoint {

  public var request: Request {
    return self
  }
}

public struct DefaultSchema: Schema {

  public typealias EndpointType = Request
  public let baseUrl: URLStringConvertible = ""
  public let headers: [String: String] = [:]
  public let sessionConfiguration: SessionConfiguration = SessionConfiguration.default
}
