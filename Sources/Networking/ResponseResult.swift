import Foundation

public struct ResponseResult<T> {

  public let data: T
  public let request: NSURLRequest
  public let response: NSHTTPURLResponse
}
