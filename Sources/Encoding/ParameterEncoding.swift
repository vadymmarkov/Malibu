import Foundation

protocol ParameterEncoding {
  func encode(parameters: [String: AnyObject]) throws -> NSData?
}
