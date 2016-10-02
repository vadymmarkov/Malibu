import Foundation

public protocol ParameterEncoding {
  func encode(_ parameters: [String: AnyObject]) throws -> Data?
}
