import Foundation
import When

public class Response: Promise<NSData> {
  
  let request: NSURLRequest?
  let response: NSHTTPURLResponse?
  
  public init(request: NSURLRequest?, response: NSHTTPURLResponse?) {
    self.request = request
    self.response = response
    
    super.init()
  }
  
  public func validate<S: SequenceType where S.Generator.Element == Int>(statusCode statusCodes: S) -> Response {
    let validationResponse = Response(request: request, response: response)
    
    done({ data in
      guard let response = self.response else {
        let error =  Error.NoResponseReceived
        validationResponse.reject(error)
        return
      }
      
      guard statusCodes.contains(response.statusCode) else {
        let error =  Error.StatusCodeValidationFailed(response.statusCode)
        validationResponse.reject(error)
        return
      }
      
      validationResponse.resolve(data)
    })
    
    fail({ error in
      validationResponse.reject(error)
    })
    
    return validationResponse
  }
}
