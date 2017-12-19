import Foundation

public protocol Serializing {
  associatedtype T
  func serialize(response: Response) throws -> T
}
