import Foundation

/// Used to bundle request information to NSCoding conformance
final class RequestCapsule: NSObject, NSCoding {
  enum Key: String {
    case method
    case resource
    case parameters
    case headers
    case contentType
    case etagPolicy
    case storePolicy
    case cachePolicy
  }

  let request: Request

  var id: String {
    return request.resource.urlString
  }

  // MARK: - Initialization

  init(request: Request) {
    self.request = request
  }

  required init?(coder aDecoder: NSCoder) {
    guard
      let methodString = aDecoder.decodeObject(forKey: Key.method.rawValue) as? String,
      let method = Method(rawValue: methodString),
      let resource = aDecoder.decodeObject(forKey: Key.resource.rawValue) as? String,
      let parameters = aDecoder.decodeObject(forKey: Key.parameters.rawValue) as? [String: Any],
      let headers = aDecoder.decodeObject(forKey: Key.headers.rawValue) as? [String: String],
      let etagPolicy = EtagPolicy(rawValue: aDecoder.decodeCInt(forKey: Key.etagPolicy.rawValue)),
      let storePolicy = StorePolicy(rawValue: aDecoder.decodeCInt(forKey: Key.storePolicy.rawValue)),
      let cachePolicy = NSURLRequest.CachePolicy(rawValue: UInt(aDecoder.decodeCInt(forKey: Key.cachePolicy.rawValue)))
    else {
      return nil
    }

    self.request = Request(
      method: method,
      resource: resource,
      contentType: ContentType(header: aDecoder.decodeObject(forKey: Key.contentType.rawValue) as? String),
      parameters: parameters,
      headers: headers,
      etagPolicy: etagPolicy,
      storePolicy: storePolicy,
      cachePolicy: cachePolicy)
  }

  // MARK: - Encoding

  func encode(with aCoder: NSCoder) {
    aCoder.encode(request.method.rawValue, forKey: Key.method.rawValue)
    aCoder.encode(request.resource.urlString, forKey: Key.resource.rawValue)
    aCoder.encode(request.parameters, forKey: Key.parameters.rawValue)
    aCoder.encode(request.headers, forKey: Key.headers.rawValue)
    aCoder.encode(request.contentType.header, forKey: Key.contentType.rawValue)
    aCoder.encodeCInt(request.etagPolicy.rawValue, forKey: Key.etagPolicy.rawValue)
    aCoder.encodeCInt(request.storePolicy.rawValue, forKey: Key.storePolicy.rawValue)
    aCoder.encodeCInt(Int32(request.cachePolicy.rawValue), forKey: Key.cachePolicy.rawValue)
  }
}
