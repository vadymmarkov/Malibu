import Foundation
import When

protocol ResponseHandler {
  var urlRequest: URLRequest { get }
  var ride: Ride { get }
}

extension ResponseHandler {

  func handle(data: Data?, response: URLResponse?, error: Error?) {
    if let error = error {
      ride.reject(error)
      return
    }

    guard let response = response as? HTTPURLResponse else {
      ride.reject(NetworkError.noResponseReceived)
      return
    }

    guard let data = data else {
      ride.reject(NetworkError.noDataInResponse)
      return
    }

    let result = Wave(data: data, request: urlRequest, response: response)
    ride.resolve(result)
  }
}
