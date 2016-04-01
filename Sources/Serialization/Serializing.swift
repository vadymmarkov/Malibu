import Foundation

public protocol Serializing {
  associatedtype T

  func serialize(data: NSData, response: NSHTTPURLResponse) throws -> T
}
