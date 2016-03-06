import Foundation
import When

public class Response<T>: Promise<T> {

  var request: NSURLRequest?
  var response: NSHTTPURLResponse?

  // MARK: - Initialization

  public init(request: NSURLRequest? = nil, response: NSHTTPURLResponse? = nil) {
    self.request = request
    self.response = response

    super.init()
  }

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
      guard let accept = request?.valueForHTTPHeaderField("Accept") else {
        return ["*/*"]
      }

      return accept.componentsSeparatedByString(",")
    }()

    return validate(statusCodes: statusCodes).validate(contentTypes: contentTypes)
  }
}
