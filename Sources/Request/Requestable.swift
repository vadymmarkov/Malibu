import Foundation

public protocol Requestable {
  var method: Method { get }
  var message: Message { get set }
  var contentType: ContentType { get }
  var etagPolicy: ETagPolicy { get }
  var cachePolicy: NSURLRequestCachePolicy { get }

  func toURLRequest(baseURLString: URLStringConvertible?,
                    additionalHeaders: [String: String]) throws -> NSMutableURLRequest
}

public extension Requestable {

  // MARK: - Default implementations

  var cachePolicy: NSURLRequestCachePolicy {
    return .UseProtocolCachePolicy
  }

  func toURLRequest(baseURLString: URLStringConvertible? = nil,
                           additionalHeaders: [String: String] = [:]) throws -> NSMutableURLRequest {
    let prefix = baseURLString?.URLString ?? ""
    let resourceString = "\(prefix)\(message.resource.URLString)"
    let URL = try buildURL(resourceString)
    let request = NSMutableURLRequest(URL: URL)

    request.HTTPMethod = method.rawValue
    request.cachePolicy = cachePolicy

    if let contentTypeHeader = contentType.header {
      request.setValue(contentTypeHeader, forHTTPHeaderField: "Content-Type")
    }

    if let encoder = parameterEncoders[contentType] {
      request.HTTPBody = try encoder.encode(message.parameters)
    }

    [additionalHeaders, message.headers].forEach {
      $0.forEach { key, value in
        request.setValue(value, forHTTPHeaderField: key)
      }
    }

    if etagPolicy == .Enabled {
      if let etag = ETagStorage().get(etagKey(prefix)) {
        request.setValue(etag, forHTTPHeaderField: "If-None-Match")
      }
    }

    return request
  }

  // MARK: - Helpers

  func buildURL(string: String) throws -> NSURL {
    guard let URL = NSURL(string: string) else {
      throw Error.InvalidRequestURL
    }

    guard contentType == .Query && !message.parameters.isEmpty else {
      return URL
    }

    guard let URLComponents = NSURLComponents(URL: URL, resolvingAgainstBaseURL: false) else {
      return URL
    }

    let percentEncodedQuery = (URLComponents.percentEncodedQuery.map { $0 + "&" } ?? "")
      + QueryBuilder().buildQuery(message.parameters)

    URLComponents.percentEncodedQuery = percentEncodedQuery

    guard let queryURL = URLComponents.URL else {
      throw Error.InvalidRequestURL
    }

    return queryURL
  }

  func etagKey(prefix: String = "") -> String {
    return "\(method.rawValue)\(prefix)\(message.resource.URLString)\(message.parameters.description)"
  }

  var key: String {
    return "\(method) \(message.resource.URLString)"
  }
}
