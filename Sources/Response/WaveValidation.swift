import Foundation
import When

// MARK: - Validations

public extension Promise where T: Wave {

  public func validate(_ validator: Validating) -> Promise<Wave> {
    return then({ result -> Wave in
      try validator.validate(result)
      return result
    })
  }

  public func validate<T: Sequence>(statusCodes: T) -> Promise<Wave> where T.Iterator.Element == Int {
    return validate(StatusCodeValidator(statusCodes: statusCodes))
  }

  public func validate<T : Sequence>(contentTypes: T) -> Promise<Wave> where T.Iterator.Element == String {
    return validate(ContentTypeValidator(contentTypes: contentTypes))
  }

  public func validate() -> Promise<Wave> {
    return validate(statusCodes: 200..<300).then({ result -> Wave in
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
