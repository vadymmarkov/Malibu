import Foundation
import When

public typealias Validation = (response: NSHTTPURLResponse) -> ErrorType?

public protocol Validating {
  func validateResponse(response: NSHTTPURLResponse) throws
}

extension Validating {

  func validate<T>(response: Response<T>) -> Response<T> {
    let validationResponse = Response<T>(request: response.request, response: response.response)
    let validate = validateResponse

    response.done({ data in
      guard let resolvedResponse = response.response else {
        let error =  Error.NoResponseReceived
        validationResponse.reject(error)
        return
      }

      validationResponse.request = response.request
      validationResponse.response = resolvedResponse

      do {
        try validate(resolvedResponse)
      } catch {
        validationResponse.reject(error)
        return
      }

      validationResponse.resolve(data)
    })

    response.fail({ error in
      validationResponse.reject(error)
    })

    return validationResponse
  }
}
