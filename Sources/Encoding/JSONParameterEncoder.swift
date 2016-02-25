import Foundation

public struct JSONParameterEncoder: ParameterEncoding {
  
  public func encode(parameters: [String: AnyObject]) throws -> NSData? {
    let data = try NSJSONSerialization.dataWithJSONObject(parameters,
      options: NSJSONWritingOptions())
    
    return data
  }
}
