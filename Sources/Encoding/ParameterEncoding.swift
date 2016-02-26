import Foundation

public protocol ParameterEncoding {
  func encode(parameters: [String: AnyObject]) throws -> NSData?
}
