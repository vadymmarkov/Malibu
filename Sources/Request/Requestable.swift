import Foundation

//var methodsWithEtags: [Method] = [.GET, .PATCH, .PUT]

public protocol Requestable {
  var method: Method { get }
  var message: Message { get }
  var contentType: ContentType { get }
  var etagPolicy: ETagPolicy { get }

  func toURLRequest(baseURLString: URLStringConvertible?,
                    additionalHeaders: [String: String]) throws -> NSMutableURLRequest
}

extension Requestable {

  public func toURLRequest(baseURLString: URLStringConvertible? = nil,
                           additionalHeaders: [String: String] = [:]) throws -> NSMutableURLRequest {
    let prefix = baseURLString?.URLString ?? ""
    let resourceString = "\(prefix)\(message.resource.URLString)"

    guard let URL = NSURL(string: resourceString) else {
      throw Error.InvalidRequestURL
    }

    let request = NSMutableURLRequest(URL: URL)
    request.HTTPMethod = method.rawValue
    request.cachePolicy = message.cachePolicy

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
      if let etag = ETagStorage().get(message.etagKey(prefix)) {
        request.setValue(etag, forHTTPHeaderField: "If-None-Match")
      }
    }

    return request
  }
}
