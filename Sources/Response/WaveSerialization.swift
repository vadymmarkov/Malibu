import Foundation
import When

// MARK: - Serialization

public extension Promise where T: Wave {

  public func toData() -> Promise<Data> {
    return then({ result -> Data in
      return try DataSerializer().serialize(result.data, response: result.response)
    })
  }

  public func toString(_ encoding: String.Encoding? = nil) -> Promise<String> {
    return then({ result -> String in
      return try StringSerializer(encoding: encoding).serialize(result.data, response: result.response)
    })
  }

  public func toJSONArray(_ options: JSONSerialization.ReadingOptions = .allowFragments) -> Promise<[[String: AnyObject]]> {
    return then({ result -> [[String: AnyObject]] in
      let serializer = JSONSerializer(options: options)

      let data = try serializer.serialize(result.data,
        response: result.response)

      guard !(data is NSNull) else {
        return []
      }

      guard let array = data as? [[String : AnyObject]]
        else { throw NetworkError.jsonArraySerializationFailed }

      return array
    })
  }

  public func toJSONDictionary(_ options: JSONSerialization.ReadingOptions = .allowFragments) -> Promise<[String: AnyObject]> {
    return then({ result -> [String: AnyObject] in
      let serializer = JSONSerializer(options: options)

      let data = try serializer.serialize(result.data,
        response: result.response)

      guard !(data is NSNull) else {
        return [:]
      }

      guard let dictionary = data as? [String : AnyObject]
        else { throw NetworkError.jsonDictionarySerializationFailed }

      return dictionary
    })
  }
}
