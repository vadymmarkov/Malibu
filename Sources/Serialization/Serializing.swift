import Foundation

public protocol Serializing {
  typealias T

  func serialize(data: NSData, response: NSHTTPURLResponse) throws -> T
}
