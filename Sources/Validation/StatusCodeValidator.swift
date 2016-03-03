import Foundation

public struct StatusCodeValidator<T: SequenceType where T.Generator.Element == Int>: Validating {
  
  public var statusCodes: T
  
  public func validateResponse(response: NSHTTPURLResponse) throws {
    guard statusCodes.contains(response.statusCode) else {
      throw Error.UnacceptableStatusCode(response.statusCode)
    }
  }
}
