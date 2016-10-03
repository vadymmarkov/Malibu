import Foundation

public struct Message: Equatable {

  public var resource: URLStringConvertible
  public var parameters: [String: Any]
  public var headers: [String: String]

  public init(resource: URLStringConvertible,
              parameters: [String: Any] = [:],
              headers: [String: String] = [:]) {
    self.resource = resource
    self.parameters = parameters
    self.headers = headers
  }
}

public func == (lhs: Message, rhs: Message) -> Bool {
  return lhs.resource.urlString == rhs.resource.urlString
    && (lhs.parameters as NSDictionary).isEqual(rhs.parameters as NSDictionary)
    && lhs.headers == rhs.headers
}
