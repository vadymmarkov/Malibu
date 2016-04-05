import Foundation
import When

protocol TaskRunning: class {
  var URLRequest: NSURLRequest { get }
  var promise: Promise<Wave> { get }

  func run() -> Ride
}

extension TaskRunning {

  func process(data: NSData?, response: NSURLResponse?, error: ErrorType?) {
    if let error = error {
      promise.reject(error)
      return
    }

    guard let response = response as? NSHTTPURLResponse else {
      promise.reject(Error.NoResponseReceived)
      return
    }

    guard let data = data else {
      promise.reject(Error.NoDataInResponse)
      return
    }

    let result = Wave(data: data, request: URLRequest, response: response)
    promise.resolve(result)
  }
}
