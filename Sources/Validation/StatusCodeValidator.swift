import Foundation

public struct StatusCodeValidator<T: SequenceType where T.Generator.Element == Int>: Validating {

  public var statusCodes: T

  public func validate(result: NetworkResult) throws {
    guard statusCodes.contains(result.response.statusCode) else {
      throw Error.UnacceptableStatusCode(result.response.statusCode)
    }
  }
}
