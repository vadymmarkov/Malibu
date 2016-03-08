import Foundation
import When

public class NetworkResult: Equatable {

  public let data: NSData
  public let request: NSURLRequest
  public let response: NSHTTPURLResponse
  
  public init(data: NSData, request: NSURLRequest, response: NSHTTPURLResponse) {
    self.data = data
    self.request = request
    self.response = response
  }
}

// MARK: - Equatable

public func ==(lhs: NetworkResult, rhs: NetworkResult) -> Bool {
  return lhs.data == rhs.data
    && lhs.request == rhs.request
    && lhs.response == rhs.response
}

public extension Promise where T: NetworkResult {
  
  // MARK: - Validation
  
  public func validate(validator: Validating) -> Promise<NetworkResult> {
    return then({ result -> NetworkResult in
      try validator.validate(result.response)
      return result
    })
  }
  
  public func validate<T: SequenceType where T.Generator.Element == Int>(statusCodes statusCodes: T) -> Promise<NetworkResult> {
    return validate(StatusCodeValidator(statusCodes: statusCodes))
  }
  
  public func validate<T : SequenceType where T.Generator.Element == String>(contentTypes contentTypes: T) -> Promise<NetworkResult> {
    return validate(ContentTypeValidator(contentTypes: contentTypes))
  }
  
  public func validate() -> Promise<NetworkResult> {
    return validate(statusCodes: 200..<300).then({ result -> NetworkResult in
      let contentTypes: [String]
      
      if let accept = result.request.valueForHTTPHeaderField("Accept") {
        contentTypes = accept.componentsSeparatedByString(",")
      } else {
        contentTypes = ["*/*"]
      }
      
      try ContentTypeValidator(contentTypes: contentTypes).validate(result.response)
      return result
    })
  }
  
  // MARK: - Serialization
  
  public func toJSONArray() -> Promise<[[String: AnyObject]]> {
    return then({ result -> [[String: AnyObject]] in
      let serializer = JSONSerializer()
      
      guard let data = try serializer.serialize(result.data,
        response: result.response) as? [[String : AnyObject]]
        else { throw Error.NoJSONArrayInResponseData }
      
      return data
    })
  }
  
  public func toJSONDictionary() -> Promise<[String: AnyObject]> {
    return then({ result -> [String: AnyObject] in
      let serializer = JSONSerializer()
      
      guard let data = try serializer.serialize(result.data,
        response: result.response) as? [String : AnyObject]
        else { throw Error.NoJSONArrayInResponseData }
      
      return data
    })
  }
}
