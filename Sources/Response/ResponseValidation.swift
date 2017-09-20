import Foundation
import When

// MARK: - Validations

public extension Promise where T: Response {
  public func validate(using validator: Validating) -> Promise<Response> {
    return then({ result -> Response in
      try validator.validate(result)
      return result
    })
  }

  public func validate<T: Sequence>(statusCodes: T) -> Promise<Response> where T.Iterator.Element == Int {
    return validate(using: StatusCodeValidator(statusCodes: statusCodes))
  }

  public func validate<T: Sequence>(contentTypes: T) -> Promise<Response> where T.Iterator.Element == String {
    return validate(using: ContentTypeValidator(contentTypes: contentTypes))
  }

  public func validate() -> Promise<Response> {
    return validate(statusCodes: 200..<300).then({ result -> Response in
      let contentTypes: [String]

      if let accept = result.request.value(forHTTPHeaderField: "Accept") {
        contentTypes = accept.components(separatedBy: ",")
      } else {
        contentTypes = ["*/*"]
      }

      try ContentTypeValidator(contentTypes: contentTypes).validate(result)

      return result
    })
  }
}
