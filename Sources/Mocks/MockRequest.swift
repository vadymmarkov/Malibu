import Foundation

public class MockRequest {
  public var request: Requestable
  public var response: NSHTTPURLResponse?
  public var data: NSData?
  public var error: ErrorType?
  
  // MARK: - Initialization
  
  public init(request: Requestable, response: NSHTTPURLResponse?, data: NSData?, error: ErrorType? = nil) {
    self.request = request
    self.data = data
    self.response = response
    self.error = error
  }
}
