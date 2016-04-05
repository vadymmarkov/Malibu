import Foundation

public struct ContentTypeValidator<T : SequenceType where T.Generator.Element == String>: Validating {

  public var contentTypes: T

  // MARK: - Initialization

  public init(contentTypes: T) {
    self.contentTypes = contentTypes
  }

  // MARK: - Validation

  public func validate(result: Wave) throws {
    let response = result.response

    if let responseContentType = response.MIMEType,
      responseMIMEType = MIMEType(contentType: responseContentType) {
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



