import Foundation

public struct JSONSerializer: Serializing {

  let options: NSJSONReadingOptions

  public init(options: NSJSONReadingOptions = .AllowFragments) {
    self.options = options
  }

  public func serialize(data: NSData, response: NSHTTPURLResponse) throws -> AnyObject {
    if response.statusCode == 204 { return NSNull() }

    guard data.length > 0 else {
      throw Error.NoDataInResponse
    }

    do {
      return try NSJSONSerialization.JSONObjectWithData(data, options: options)
    } catch {
      throw error
    }
  }
}
