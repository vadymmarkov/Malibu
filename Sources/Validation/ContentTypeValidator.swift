import Foundation

public struct ContentTypeValidator<T : SequenceType where T.Generator.Element == String>: Validating {

  public var contentTypes: T

  public func validateResponse(response: NSHTTPURLResponse) throws {

    if let responseContentType = response.MIMEType, responseMIMEType = MIMEType(contentType: responseContentType) {
      for contentType in contentTypes {
        if MIMEType(contentType: contentType)?.matches(responseMIMEType) == true {
          return
        }
      }
    } else {
      for contentType in contentTypes {
        let expectedMIMEType = MIMEType(contentType: contentType)

        if expectedMIMEType?.type == "*" && expectedMIMEType?.subtype == "*" {
          return
        }
      }
    }

    var error = Error.MissingContentType

    if let responseContentType = response.MIMEType {
      error = Error.UnacceptableContentType(responseContentType)
    }

    throw error
  }
}



