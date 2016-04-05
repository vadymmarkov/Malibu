import Foundation

public struct StatusCodeValidator<T: SequenceType where T.Generator.Element == Int>: Validating {

  public var statusCodes: T

  // MARK: - Initialization

  public init(statusCodes: T) {
    self.statusCodes = statusCodes
  }

  // MARK: - Validation

  public func validate(result: NetworkResult) throws {
    guard statusCodes.contains(result.response.statusCode) else {
      throw Error.UnacceptableStatusCode(result.response.statusCode)
    }
  }
}
