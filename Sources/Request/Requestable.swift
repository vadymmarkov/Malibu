import Foundation

public protocol Requestable {
  var message: Message { get set }

  func toURLRequest(method: Method,
    baseURLString: URLStringConvertible?,
    additionalHeaders: [String: String]) throws -> NSMutableURLRequest
}

extension Requestable {

  public func toURLRequest(method: Method, baseURLString: URLStringConvertible? = nil, additionalHeaders: [String: String] = [:]) throws -> NSMutableURLRequest {
    let prefix = baseURLString?.URLString ?? ""
    let resourceString = "\(prefix)\(message.resource.URLString)"

    guard let URL = NSURL(string: resourceString) else {
      throw Error.InvalidRequestURL
    }

    let contentType = message.contentType

    let request = NSMutableURLRequest(URL: URL)
    request.HTTPMethod = method.rawValue
    request.cachePolicy = message.cachePolicy
    request.setValue(contentType.value, forHTTPHeaderField: "Content-Type")

    if let encoder = parameterEncoders[contentType] {
      request.HTTPBody = try encoder.encode(message.parameters)
    }

    [additionalHeaders, message.headers].forEach {
      $0.forEach { key, value in
        request.setValue(value, forHTTPHeaderField: key)
      }
    }

    var withEtag: Bool

    switch message.etagPolicy {
    case .Default:
      withEtag = methodsWithEtags.contains(method)
    case .Enabled:
      withEtag = true
    case .Disabled:
      withEtag = false
    }

    if withEtag {
      if let etag = ETagStorage().get(message.etagKey(prefix)) {
        request.setValue(etag, forHTTPHeaderField: "If-None-Match")
      }
    }

    return request
  }
}
