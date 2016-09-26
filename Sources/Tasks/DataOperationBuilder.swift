import Foundation
import When

class DataOperationBuilder: OperationBuilder {

  var session: NSURLSession
  var URLRequest: NSURLRequest
  var ride: Ride

  // MARK: - Initialization

  init(session: NSURLSession, URLRequest: NSURLRequest, ride: Ride) {
    self.session = session
    self.URLRequest = URLRequest
    self.ride = ride
  }

  // MARK: - NetworkTaskRunning

  func build() -> NSOperation {
    let operation = DataOperation(session: session, request: URLRequest) {
      [weak self] data, response, error in

      guard let weakSelf = self else {
        return
      }

      if let error = error {
        weakSelf.ride.reject(error)
        return
      }

      guard let response = response as? NSHTTPURLResponse else {
        weakSelf.ride.reject(Error.NoResponseReceived)
        return
      }

      guard let data = data else {
        weakSelf.ride.reject(Error.NoDataInResponse)
        return
      }

      let result = Wave(data: data, request: weakSelf.URLRequest, response: response)
      weakSelf.ride.resolve(result)
    }
    
    ride.operation = operation

    return operation
  }
}
