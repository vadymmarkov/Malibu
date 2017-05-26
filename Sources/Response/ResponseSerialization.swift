import Foundation
import When

// MARK: - Serialization

public extension Promise where T: Response {

  public func toData() -> Promise<Data> {
    return then({ result -> Data in
      return try DataSerializer().serialize(data: result.data, response: result.response)
    })
  }

  public func toString(_ encoding: String.Encoding? = nil) -> Promise<String> {
    return then({ result -> String in
      return try StringSerializer(encoding: encoding).serialize(
        data: result.data,
        response: result.response
      )
    })
  }

  public func toJsonArray(_ options: JSONSerialization.ReadingOptions = .allowFragments) -> Promise<[[String: Any]]> {
    return then({ result -> [[String: Any]] in
      let serializer = JsonSerializer(options: options)

      let data = try serializer.serialize(
        data: result.data,
        response: result.response
      )

      guard !(data is NSNull) else {
        return []
      }

      guard let array = data as? [[String : Any]]
        else { throw NetworkError.jsonArraySerializationFailed }

      return array
    })
  }

  public func toJsonDictionary(_ options: JSONSerialization.ReadingOptions = .allowFragments) -> Promise<[String: Any]> {
    return then({ result -> [String: Any] in
      let serializer = JsonSerializer(options: options)

      let data = try serializer.serialize(
        data: result.data,
        response: result.response
      )

      guard !(data is NSNull) else {
        return [:]
      }

      guard let dictionary = data as? [String : Any]
        else { throw NetworkError.jsonDictionarySerializationFailed }

      return dictionary
    })
  }
}
