import Foundation

public protocol Serializing {
  associatedtype T

  func serialize(data: Data, response: HTTPURLResponse) throws -> T
}
