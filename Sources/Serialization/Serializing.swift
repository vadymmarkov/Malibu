import Foundation

public protocol Serializing {
  func serialize(data: NSData, response: NSHTTPURLResponse) throws
}
