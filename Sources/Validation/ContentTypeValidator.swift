import Foundation

public final class ContentTypeValidator<T: Sequence>: Validating where T.Iterator.Element == String {
  private let contentTypes: T

  // MARK: - Initialization

  public init(contentTypes: T) {
    self.contentTypes = contentTypes
  }

  // MARK: - Validation

  public func validate(_ result: Response) throws {
    let response = result.response

    if let responseContentType = response.mimeType,
      let responseMimeType = MimeType(contentType: responseContentType) {
      for contentType in contentTypes {
        if MimeType(contentType: contentType)?.matches(to: responseMimeType) == true {
          return
        }
      }
    } else {
      for contentType in contentTypes {
        let expectedMimeType = MimeType(contentType: contentType)

        if expectedMimeType?.type == "*" && expectedMimeType?.subtype == "*" {
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
