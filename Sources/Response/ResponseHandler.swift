import Foundation
import When

struct ResponseHandler {
  let urlRequest: URLRequest
  let networkPromise: NetworkPromise
}

extension ResponseHandler {
  func handle(data: Data?, urlResponse: URLResponse?, error: Error?) {
    if let error = error {
      networkPromise.reject(error)
      return
    }

    guard let urlResponse = urlResponse as? HTTPURLResponse else {
      networkPromise.reject(NetworkError.noResponseReceived)
      return
    }

    guard let data = data else {
      networkPromise.reject(NetworkError.noDataInResponse)
      return
    }

    let result = Response(data: data, request: urlRequest, response: urlResponse)
    networkPromise.resolve(result)
  }
}
