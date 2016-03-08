import Foundation

public struct DataSerializer: Serializing {
  
  public func serialize(data: NSData, response: NSHTTPURLResponse) throws -> NSData {
    if response.statusCode == 204 { return NSData() }
    
    guard data.length > 0 else {
      throw Error.NoDataInResponse
    }
    
    return data
  }
}
