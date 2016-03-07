import Foundation

public struct ResponseError: ErrorType {
  public let error: ErrorType
  public let request: NSURLRequest
  public let response: NSHTTPURLResponse
}
