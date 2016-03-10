import Foundation

protocol Requestable {
  var URL: URLStringConvertible { get }
  var contentType: ContentType { get }
  var cachePolicy: NSURLRequestCachePolicy { get }
  var forceUseETag: Bool { get }
  var parameters: [String: AnyObject] { get }
  var headers: [String: String] { get }
  
  func toURLRequest(method: Method) throws -> NSMutableURLRequest
}

extension Requestable {
  
  var contentType: ContentType {
    return .JSON
  }
  
  var cachePolicy: NSURLRequestCachePolicy {
    return .UseProtocolCachePolicy
  }

  var forceUseETag: Bool {
    return false
  }
  
  var parameters: [String: AnyObject] {
    return [:]
  }

  var headers: [String: String] {
    return [:]
  }
  
  func toURLRequest(method: Method) throws -> NSMutableURLRequest {
    guard let URL = NSURL(string: URL.URLString) else {
      throw Error.InvalidRequestURL
    }
    
    let request = NSMutableURLRequest(URL: URL)
    request.HTTPMethod = method.rawValue
    request.addValue(contentType.value, forHTTPHeaderField: "Content-Type")
    
    if let encoder = parameterEncoders[contentType] {
      request.HTTPBody = try encoder.encode(parameters)
    }
    
    return request
  }
}
