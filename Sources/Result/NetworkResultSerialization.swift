import Foundation
import When

// MARK: - Serialization

public extension Promise where T: NetworkResult {

  public func toData() -> Promise<NSData> {
    return then({ result -> NSData in
      return try DataSerializer().serialize(result.data, response: result.response)
    })
  }

  public func toString(encoding: NSStringEncoding? = nil) -> Promise<String> {
    return then({ result -> String in
      return try StringSerializer(encoding: encoding).serialize(result.data, response: result.response)
    })
  }

  public func toJSONArray(options: NSJSONReadingOptions = .AllowFragments) -> Promise<[[String: AnyObject]]> {
    return then({ result -> [[String: AnyObject]] in
      let serializer = JSONSerializer(options: options)

      let data = try serializer.serialize(result.data,
        response: result.response)

      guard !(data is NSNull) else {
        return []
      }

      guard let array = data as? [[String : AnyObject]]
        else { throw Error.JSONArraySerializationFailed }

      return array
    })
  }

  public func toJSONDictionary(options: NSJSONReadingOptions = .AllowFragments) -> Promise<[String: AnyObject]> {
    return then({ result -> [String: AnyObject] in
      let serializer = JSONSerializer(options: options)

      let data = try serializer.serialize(result.data,
        response: result.response)

      guard !(data is NSNull) else {
        return [:]
      }

      guard let dictionary = data as? [String : AnyObject]
        else { throw Error.JSONDictionarySerializationFailed }

      return dictionary
    })
  }
}
