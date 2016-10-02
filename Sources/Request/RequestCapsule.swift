import Foundation

class RequestCapsule: NSObject, Requestable, NSCoding {

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

  let method: Method
  var message: Message
  let contentType: ContentType
  let etagPolicy: ETagPolicy
  let storePolicy: StorePolicy
  let cachePolicy: NSURLRequest.CachePolicy

  var id: String {
    return message.resource.urlString
  }

  // MARK: - Initialization

  init(request: Requestable) {
    method = request.method
    message = request.message
    contentType = request.contentType
    etagPolicy = request.etagPolicy
    storePolicy = request.storePolicy
    cachePolicy = request.cachePolicy
  }

  required init?(coder aDecoder: NSCoder) {
    guard let
      methodString = aDecoder.decodeObject(forKey: Key.method.rawValue) as? String,
      let method = Method(rawValue: methodString),
      let resource = aDecoder.decodeObject(forKey: Key.resource.rawValue) as? String,
      let parameters = aDecoder.decodeObject(forKey: Key.parameters.rawValue) as? [String: Any],
      let headers = aDecoder.decodeObject(forKey: Key.headers.rawValue) as? [String: String],
      let etagPolicy = ETagPolicy(rawValue: aDecoder.decodeCInt(forKey: Key.etagPolicy.rawValue)),
      let storePolicy = StorePolicy(rawValue: aDecoder.decodeCInt(forKey: Key.storePolicy.rawValue)),
      let cachePolicy = NSURLRequest.CachePolicy(rawValue: UInt(aDecoder.decodeCInt(forKey: Key.cachePolicy.rawValue)))
    else {
      return nil
    }

    self.method = method
    self.message = Message(resource: resource, parameters: parameters, headers: headers)
    self.contentType = ContentType(header: aDecoder.decodeObject(forKey: Key.contentType.rawValue) as? String)
    self.etagPolicy = etagPolicy
    self.storePolicy = storePolicy
    self.cachePolicy = cachePolicy
  }

  // MARK: - Encoding

  func encode(with aCoder: NSCoder) {
    aCoder.encode(method.rawValue, forKey: Key.method.rawValue)
    aCoder.encode(message.resource.urlString, forKey: Key.resource.rawValue)
    aCoder.encode(message.parameters, forKey: Key.parameters.rawValue)
    aCoder.encode(message.headers, forKey: Key.headers.rawValue)
    aCoder.encode(contentType.header, forKey: Key.contentType.rawValue)
    aCoder.encodeCInt(etagPolicy.rawValue, forKey: Key.etagPolicy.rawValue)
    aCoder.encodeCInt(storePolicy.rawValue, forKey: Key.storePolicy.rawValue)
    aCoder.encodeCInt(Int32(cachePolicy.rawValue), forKey: Key.cachePolicy.rawValue)
  }
}
