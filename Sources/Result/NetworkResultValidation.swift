import Foundation
import When

// MARK: - Validations

public extension Promise where T: NetworkResult {

  public func validate(validator: Validating) -> Promise<NetworkResult> {
    return then({ result -> NetworkResult in
      try validator.validate(result.response)
      return result
    })
  }

  public func validate<T: SequenceType where T.Generator.Element == Int>(statusCodes statusCodes: T) -> Promise<NetworkResult> {
    return validate(StatusCodeValidator(statusCodes: statusCodes))
  }

  public func validate<T : SequenceType where T.Generator.Element == String>(contentTypes contentTypes: T) -> Promise<NetworkResult> {
    return validate(ContentTypeValidator(contentTypes: contentTypes))
  }

  public func validate() -> Promise<NetworkResult> {
    return validate(statusCodes: 200..<300).then({ result -> NetworkResult in
      let contentTypes: [String]

      if let accept = result.request.valueForHTTPHeaderField("Accept") {
        contentTypes = accept.componentsSeparatedByString(",")
      } else {
        contentTypes = ["*/*"]
      }

      try ContentTypeValidator(contentTypes: contentTypes).validate(result.response)

      return result
    })
  }
}
