import Foundation
import When

// MARK: - Serialization

public extension Promise where T: NetworkResult {
  
  public func toData() -> Promise<NSData> {
    return then({ result -> NSData in
      return try DataSerializer().serialize(result.data, response: result.response)
    })
  }
  
  public func toString() -> Promise<String> {
    return then({ result -> String in
      return try StringSerializer().serialize(result.data, response: result.response)
    })
  }
  
  public func toJSONArray() -> Promise<[[String: AnyObject]]> {
    return then({ result -> [[String: AnyObject]] in
      let serializer = JSONSerializer()
      
      guard let data = try serializer.serialize(result.data,
        response: result.response) as? [[String : AnyObject]]
        else { throw Error.JSONArraySerializationFailed }
      
      return data
    })
  }
  
  public func toJSONDictionary() -> Promise<[String: AnyObject]> {
    return then({ result -> [String: AnyObject] in
      let serializer = JSONSerializer()
      
      guard let data = try serializer.serialize(result.data,
        response: result.response) as? [String : AnyObject]
        else { throw Error.JSONDictionarySerializationFailed }
      
      return data
    })
  }
}
