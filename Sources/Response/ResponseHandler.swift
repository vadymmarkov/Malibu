import Foundation
import When

protocol ResponseHandler {
  var urlRequest: URLRequest { get }
  var ride: Ride { get }
}

extension ResponseHandler {

  func handle(data: Data?, urlResponse: URLResponse?, error: Error?) {
    if let error = error {
      ride.reject(error)
      return
    }

    guard let urlResponse = urlResponse as? HTTPURLResponse else {
      ride.reject(NetworkError.noResponseReceived)
      return
    }

    guard let data = data else {
      ride.reject(NetworkError.noDataInResponse)
      return
    }

    let result = Response(data: data, request: urlRequest, response: urlResponse)
    ride.resolve(result)
  }
}
