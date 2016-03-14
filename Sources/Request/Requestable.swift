import Foundation

public protocol Requestable {
  var message: Message { get set }

  init()
  init(parameters: [String : AnyObject], headers: [String : String])
  
  func toURLRequest(method: Method,
    baseURLString: URLStringConvertible?,
    additionalHeaders: [String: String]) throws -> NSMutableURLRequest
}

extension Requestable {

  public init(parameters: [String : AnyObject] = [:], headers: [String : String] = [:]) {
    self.init()

    parameters.forEach { key, value in
      self.message.parameters[key] = value
    }

    headers.forEach { key, value in
      self.message.headers[key] = value
    }
  }

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
    request.addValue(contentType.value, forHTTPHeaderField: "Content-Type")

    if let encoder = parameterEncoders[contentType] {
      request.HTTPBody = try encoder.encode(message.parameters)
    }
    
    [additionalHeaders, message.headers].forEach {
      $0.forEach { key, value in
        request.addValue(value, forHTTPHeaderField: key)
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
        request.addValue(etag, forHTTPHeaderField: "If-None-Match")
      }
    }

    return request
  }
}
