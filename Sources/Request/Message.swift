import Foundation

public struct Message: Equatable {

  public var resource: URLStringConvertible
  public var parameters: [String: AnyObject]
  public var headers: [String: String]

  public init(resource: URLStringConvertible,
              parameters: [String: AnyObject] = [:],
              headers: [String: String] = [:]) {
    self.resource = resource
    self.parameters = parameters
    self.headers = headers
  }
}

public func ==(lhs: Message, rhs: Message) -> Bool {
  return lhs.resource.URLString == rhs.resource.URLString
    && (lhs.parameters as NSDictionary).isEqual(rhs.parameters as NSDictionary)
    && lhs.headers == rhs.headers
}
