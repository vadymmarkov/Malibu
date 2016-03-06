import Foundation
import When

public typealias Validation = (response: NSHTTPURLResponse) -> ErrorType?

public protocol Validating {
  func validate(response: NSHTTPURLResponse) throws
}

extension Validating {

  func attachTo<T>(response: Response<T>) -> Response<T> {
    let validationResponse = Response<T>(request: response.request, response: response.response)
    let validateResponse = validate

    response.done({ data in
      guard let HTTPResponse = response.response else {
        validationResponse.reject(Error.NoResponseReceived)
        return
      }

      validationResponse.request = response.request
      validationResponse.response = HTTPResponse

      do {
        try validateResponse(HTTPResponse)
      } catch {
        validationResponse.reject(error)
        return
      }

      validationResponse.resolve(data)
    })

    response.fail({ error in
      guard let resolvedResponse = response.response else {
        validationResponse.reject(Error.NoResponseReceived)
        return
      }

      validationResponse.request = response.request
      validationResponse.response = resolvedResponse

      validationResponse.reject(error)
    })

    return validationResponse
  }
}
