import Foundation

public struct Message: Equatable {

  public enum ETagPolicy {
    case Default
    case Enable
    case Disable
  }

  public var resource: URLStringConvertible
  public var parameters: [String: AnyObject]
  public var headers: [String: String]
  public var contentType: ContentType
  public var cachePolicy: NSURLRequestCachePolicy
  public var etagPolicy: ETagPolicy

  public init(resource: URLStringConvertible,
    parameters: [String: AnyObject] = [:],
    headers: [String: String] = [:],
    contentType: ContentType = .JSON,
    cachePolicy: NSURLRequestCachePolicy = .UseProtocolCachePolicy,
    etagPolicy: ETagPolicy = .Default) {
      self.resource = resource
      self.parameters = parameters
      self.headers = headers
      self.contentType = contentType
      self.cachePolicy = cachePolicy
      self.etagPolicy = etagPolicy
  }

  public var etagKey: String {
    return resource.URLString + parameters.description
  }
}

public func ==(lhs: Message, rhs: Message) -> Bool {
  return lhs.resource.URLString == rhs.resource.URLString
    && (lhs.parameters as NSDictionary).isEqual(rhs.parameters as NSDictionary)
    && lhs.headers == rhs.headers
    && lhs.contentType == rhs.contentType
    && lhs.cachePolicy == rhs.cachePolicy
    && lhs.etagPolicy == rhs.etagPolicy
}
