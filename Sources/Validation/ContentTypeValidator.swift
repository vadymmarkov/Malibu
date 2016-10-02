import Foundation

public struct ContentTypeValidator<T : Sequence>: Validating where T.Iterator.Element == String {

  public var contentTypes: T

  // MARK: - Initialization

  public init(contentTypes: T) {
    self.contentTypes = contentTypes
  }

  // MARK: - Validation

  public func validate(_ result: Wave) throws {
    let response = result.response

    if let responseContentType = response.mimeType,
      let responseMIMEType = MIMEType(contentType: responseContentType) {
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

    var error = NetworkError.missingContentType

    if let responseContentType = response.mimeType {
      error = NetworkError.unacceptableContentType(responseContentType)
    }

    throw error
  }
}
