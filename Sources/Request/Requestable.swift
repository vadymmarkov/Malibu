import Foundation

public protocol Requestable {
  var method: Method { get }
  var message: Message { get set }
  var contentType: ContentType { get }
  var etagPolicy: ETagPolicy { get }
  var storePolicy: StorePolicy { get }
  var cachePolicy: NSURLRequestCachePolicy { get }

  func toURLRequest(baseURLString: URLStringConvertible?,
                    additionalHeaders: [String: String]) throws -> NSMutableURLRequest
}

public extension Requestable {

  // MARK: - Default implementations

  var storePolicy: StorePolicy {
    return .Unspecified
  }

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

    var data: NSData?

    if let encoder = parameterEncoders[contentType] {
      data = try encoder.encode(message.parameters)
    } else if let encoder = contentType.encoder {
      data = try encoder.encode(message.parameters)
    }

    request.HTTPBody = data

    if let body = data where contentType == .MultipartFormData {
      request.setValue("\(body.length)", forHTTPHeaderField: "Content-Length")
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
    return "\(method)\(prefix)\(message.resource.URLString)\(message.parameters.description)"
  }

  var key: String {
    return "\(method) \(message.resource.URLString)"
  }
}
