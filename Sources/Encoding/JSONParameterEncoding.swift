import Foundation

struct JSONParameterEncoding: ParameterEncoding {
  
  func encode(parameters: [String: AnyObject]) throws -> NSData? {
    let data = try NSJSONSerialization.dataWithJSONObject(parameters,
      options: NSJSONWritingOptions())
    
    return data
  }
}
