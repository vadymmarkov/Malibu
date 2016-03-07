import Foundation
import When

public class Response<T>: Promise<T> {

  var result: ResponseResult<T>?

  // MARK: - Initialization

  public init() {
    super.init()
  }

  // MARK: - Validations

  public func validate(validator: Validating) -> Response {
    return validator.attachTo(self)
  }

  public func validate<T: SequenceType where T.Generator.Element == Int>(statusCodes statusCodes: T) -> Response {
    return validate(StatusCodeValidator(statusCodes: statusCodes))
  }

  public func validate<T : SequenceType where T.Generator.Element == String>(contentTypes contentTypes: T) -> Response {
    return validate(ContentTypeValidator(contentTypes: contentTypes))
  }

  public func validate() -> Response {
    let statusCodes = 200..<300

    let contentTypes: [String] = {
      guard let accept = result?.request.valueForHTTPHeaderField("Accept") else {
        return ["*/*"]
      }

      return accept.componentsSeparatedByString(",")
    }()

    return validate(statusCodes: statusCodes).validate(contentTypes: contentTypes)
  }
}

extension Response where T: NSData {

  public func toJSONArray() -> Promise<[[String: AnyObject]]> {
    return then({ data -> [[String: AnyObject]] in
      guard let HTTPResponse = self.result?.response else {
        throw Error.NoResponseReceived
      }

      let serializer = JSONSerializer()

      guard let result = try serializer.serialize(data, response: HTTPResponse) as? [[String : AnyObject]] else {
        throw Error.NoJSONArrayInResponseData
      }

      return result
    })
  }
}
