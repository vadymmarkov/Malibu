import Foundation

class RequestCapsule: NSObject, Requestable, NSCoding {

  enum Key: String {
    case Method
    case Resource
    case Parameters
    case Headers
    case ContentType
    case EtagPolicy
    case StorePolicy
    case CachePolicy
  }

  let method: Method
  var message: Message
  let contentType: ContentType
  let etagPolicy: ETagPolicy
  let storePolicy: StorePolicy
  let cachePolicy: NSURLRequestCachePolicy

  var id: String {
    return message.resource.URLString
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
      methodString = aDecoder.decodeObjectForKey(Key.Method.rawValue) as? String,
      method = Method(rawValue: methodString),
      resource = aDecoder.decodeObjectForKey(Key.Resource.rawValue) as? String,
      parameters = aDecoder.decodeObjectForKey(Key.Parameters.rawValue) as? [String: AnyObject],
      headers = aDecoder.decodeObjectForKey(Key.Headers.rawValue) as? [String: String],
      etagPolicy = ETagPolicy(rawValue: aDecoder.decodeIntForKey(Key.EtagPolicy.rawValue)),
      storePolicy = StorePolicy(rawValue: aDecoder.decodeIntForKey(Key.StorePolicy.rawValue)),
      cachePolicy = NSURLRequestCachePolicy(rawValue: UInt(aDecoder.decodeIntForKey(Key.CachePolicy.rawValue)))
    else {
      return nil
    }

    self.method = method
    self.message = Message(resource: resource, parameters: parameters, headers: headers)
    self.contentType = ContentType(header: aDecoder.decodeObjectForKey(Key.ContentType.rawValue) as? String)
    self.etagPolicy = etagPolicy
    self.storePolicy = storePolicy
    self.cachePolicy = cachePolicy
  }

  // MARK: - Encoding

  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(method.rawValue, forKey: Key.Method.rawValue)
    aCoder.encodeObject(message.resource.URLString, forKey: Key.Resource.rawValue)
    aCoder.encodeObject(message.parameters, forKey: Key.Parameters.rawValue)
    aCoder.encodeObject(message.headers, forKey: Key.Headers.rawValue)
    aCoder.encodeObject(contentType.header, forKey: Key.ContentType.rawValue)
    aCoder.encodeInt(etagPolicy.rawValue, forKey: Key.EtagPolicy.rawValue)
    aCoder.encodeInt(storePolicy.rawValue, forKey: Key.StorePolicy.rawValue)
    aCoder.encodeInt(Int32(cachePolicy.rawValue), forKey: Key.CachePolicy.rawValue)
  }
}
