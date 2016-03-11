import Foundation

public protocol Requestable {
  var message: Message { get set }

  init()
  init(parameters: [String : AnyObject], headers: [String : String])
  func toURLRequest(method: Method) throws -> NSMutableURLRequest
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

  public func toURLRequest(method: Method) throws -> NSMutableURLRequest {
    guard let URL = NSURL(string: message.resource.URLString) else {
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

    message.headers.forEach { key, value in
      request.addValue(value, forHTTPHeaderField: key)
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
      if let etag = ETagStorage().get(message.etagKey) {
        request.addValue(etag, forHTTPHeaderField: "If-None-Match")
      }
    }

    return request
  }
}
