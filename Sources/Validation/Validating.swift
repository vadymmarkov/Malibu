import Foundation
import When

public typealias Validation = (response: NSHTTPURLResponse) -> ErrorType?

public protocol Validating {
  func validateResponse(response: NSHTTPURLResponse) throws
}

extension Validating {
  
  func validate(response: Response) -> Response {
    let validationResponse = Response(request: response.request, response: response.response)
    let validate = validateResponse
    
    response.done({ data in
      guard let response = response.response else {
        let error =  Error.NoResponseReceived
        validationResponse.reject(error)
        return
      }
      
      do {
        try validate(response)
      } catch {
        validationResponse.reject(error)
        return
      }
      
      validationResponse.resolve(data)
    })
    
    response.fail({ error in
      validationResponse.reject(error)
    })
    
    return validationResponse
  }
}
