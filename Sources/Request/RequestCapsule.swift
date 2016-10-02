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
      methodString = aDecoder.decodeObject(forKey: Key.Method.rawValue) as? String,
      let method = Method(rawValue: methodString),
      let resource = aDecoder.decodeObject(forKey: Key.Resource.rawValue) as? String,
      let parameters = aDecoder.decodeObject(forKey: Key.Parameters.rawValue) as? [String: AnyObject],
      let headers = aDecoder.decodeObject(forKey: Key.Headers.rawValue) as? [String: String],
      let etagPolicy = ETagPolicy(rawValue: aDecoder.decodeCInt(forKey: Key.EtagPolicy.rawValue)),
      let storePolicy = StorePolicy(rawValue: aDecoder.decodeCInt(forKey: Key.StorePolicy.rawValue)),
      let cachePolicy = NSURLRequest.CachePolicy(rawValue: UInt(aDecoder.decodeCInt(forKey: Key.CachePolicy.rawValue)))
    else {
      return nil
    }

    self.method = method
    self.message = Message(resource: resource, parameters: parameters, headers: headers)
    self.contentType = ContentType(header: aDecoder.decodeObject(forKey: Key.ContentType.rawValue) as? String)
    self.etagPolicy = etagPolicy
    self.storePolicy = storePolicy
    self.cachePolicy = cachePolicy
  }

  // MARK: - Encoding

  func encode(with aCoder: NSCoder) {
    aCoder.encode(method.rawValue, forKey: Key.Method.rawValue)
    aCoder.encode(message.resource.urlString, forKey: Key.Resource.rawValue)
    aCoder.encode(message.parameters, forKey: Key.Parameters.rawValue)
    aCoder.encode(message.headers, forKey: Key.Headers.rawValue)
    aCoder.encode(contentType.header, forKey: Key.ContentType.rawValue)
    aCoder.encodeCInt(etagPolicy.rawValue, forKey: Key.EtagPolicy.rawValue)
    aCoder.encodeCInt(storePolicy.rawValue, forKey: Key.StorePolicy.rawValue)
    aCoder.encodeCInt(Int32(cachePolicy.rawValue), forKey: Key.CachePolicy.rawValue)
  }
}
