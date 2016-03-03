import Foundation

public struct ContentTypeValidator<T : SequenceType where T.Generator.Element == String>: Validating {
  
  public var contentTypes: T
  
  public func validateResponse(response: NSHTTPURLResponse) throws {
    if let responseContentType = response.MIMEType, responseMIMEType = MIMEType(contentType: responseContentType) {
      contentTypes.forEach {
        if MIMEType(contentType: $0)?.matches(responseMIMEType) == true {
          return
        }
      }
    } else {
      contentTypes.forEach {
        let expectedMIMEType = MIMEType(contentType: $0)
        
        if expectedMIMEType?.type == "*" && expectedMIMEType?.subtype == "*" {
          return
        }
      }
    }
      
    var error: ErrorType
      
    if let responseContentType = response.MIMEType {
      error = Error.UnacceptableContentType(responseContentType)
    } else {
      error = Error.MissingContentType
    }
      
    throw error
  }
}



