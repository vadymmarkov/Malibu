import Foundation
import When

public class Response: Promise<NSData> {
  
  public let request: NSURLRequest?
  public let response: NSHTTPURLResponse?
  
  public let data: NSData?
  
  
  public init(request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?) {
    self.request = request
    self.response = response
    self.data = data
    
    super.init()
  }
}
