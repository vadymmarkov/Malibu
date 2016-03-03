import Foundation
import When

public class Response<T>: Promise<T> {
  
  let request: NSURLRequest?
  let response: NSHTTPURLResponse?
  
  // MARK: - Initialization
  
  public init(request: NSURLRequest?, response: NSHTTPURLResponse?) {
    self.request = request
    self.response = response
    
    super.init()
  }
  
  public func validate(validator: Validating) -> Response {
    return validator.validate(self)
  }
  
  public func validate<T: SequenceType where T.Generator.Element == Int>(statusCodes statusCodes: T) -> Response {
    return StatusCodeValidator(statusCodes: statusCodes).validate(self)
  }
  
  public func validate<T : SequenceType where T.Generator.Element == String>(contentTypes contentTypes: T) -> Response {
    return ContentTypeValidator(contentTypes: contentTypes).validate(self)
  }
  
  public func validate() -> Response {
    let statusCodes = 200..<300
    
    let contentTypes: [String] = {
      guard let accept = request?.valueForHTTPHeaderField("Accept") else {
        return ["*/*"]
      }

      return accept.componentsSeparatedByString(",")
    }()

    return validate(statusCodes: statusCodes).validate(contentTypes: contentTypes)
  }
}
