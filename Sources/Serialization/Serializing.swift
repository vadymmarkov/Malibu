import Foundation

public protocol Serializing {
  associatedtype T

  func serialize(_ data: Data, response: HTTPURLResponse) throws -> T
}
