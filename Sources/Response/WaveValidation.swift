import Foundation
import When

// MARK: - Validations

public extension Ride {

  public func validate(validator: Validating) -> Promise<Wave> {
    return then({ result -> Wave in
      try validator.validate(result)
      return result
    })
  }

  public func validate<T: SequenceType where T.Generator.Element == Int>(statusCodes statusCodes: T) -> Promise<Wave> {
    return validate(StatusCodeValidator(statusCodes: statusCodes))
  }

  public func validate<T : SequenceType where T.Generator.Element == String>(contentTypes contentTypes: T) -> Promise<Wave> {
    return validate(ContentTypeValidator(contentTypes: contentTypes))
  }

  public func validate() -> Promise<Wave> {
    return validate(statusCodes: 200..<300).then({ result -> Wave in
      let contentTypes: [String]

      if let accept = result.request.valueForHTTPHeaderField("Accept") {
        contentTypes = accept.componentsSeparatedByString(",")
      } else {
        contentTypes = ["*/*"]
      }

      try ContentTypeValidator(contentTypes: contentTypes).validate(result)

      return result
    })
  }
}
