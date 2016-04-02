import Foundation

public struct Message: Equatable {

  public var resource: URLStringConvertible
  public var parameters: [String: AnyObject]
  public var headers: [String: String]
  public var cachePolicy: NSURLRequestCachePolicy

  public init(
    resource: URLStringConvertible,
    parameters: [String: AnyObject] = [:],
    headers: [String: String] = [:],
    cachePolicy: NSURLRequestCachePolicy = .UseProtocolCachePolicy) {
    self.resource = resource
    self.parameters = parameters
    self.headers = headers
    self.cachePolicy = cachePolicy
  }

  public func etagKey(prefix: String = "") -> String {
    return "\(prefix)\(resource.URLString)\(parameters.description)"
  }
}

public func ==(lhs: Message, rhs: Message) -> Bool {
  return lhs.resource.URLString == rhs.resource.URLString
    && (lhs.parameters as NSDictionary).isEqual(rhs.parameters as NSDictionary)
    && lhs.headers == rhs.headers
    && lhs.cachePolicy == rhs.cachePolicy
}
