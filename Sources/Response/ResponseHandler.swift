import Foundation
import When

final class ResponseHandler {
  let networkPromise: NetworkPromise

  init(networkPromise: NetworkPromise) {
    self.networkPromise = networkPromise
  }
}

extension ResponseHandler {
  func handle(urlRequest: URLRequest?, data: Data?, urlResponse: URLResponse?, error: Error?) {
    if let error = error {
      networkPromise.reject(error)
      return
    }

    guard let urlRequest = urlRequest else {
      networkPromise.reject(NetworkError.invalidRequestURL)
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

    let response = Response(data: data, urlRequest: urlRequest, httpUrlResponse: urlResponse)
    networkPromise.resolve(response)
  }
}
