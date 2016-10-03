import Foundation

public protocol ParameterEncoding {
  func encode(parameters: [String: Any]) throws -> Data?
}
