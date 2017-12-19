import Foundation

public final class ContentTypeValidator<T: Sequence>: Validating where T.Iterator.Element == String {
  private let contentTypes: T

  // MARK: - Initialization

  public init(contentTypes: T) {
    self.contentTypes = contentTypes
  }

  // MARK: - Validation

  public func validate(_ response: Response) throws {
    let httpUrlResponse = response.httpUrlResponse

    if let responseContentType = httpUrlResponse.mimeType,
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

    var error = NetworkError.missingContentType(response: response)

    if let responseContentType = httpUrlResponse.mimeType {
      error = NetworkError.unacceptableContentType(
        contentType: responseContentType,
        response: response
      )
    }

    throw error
  }
}
