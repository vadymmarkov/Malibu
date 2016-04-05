import Foundation
import When

class MockDataTask: TaskRunning {

  let mock: Mock
  let URLRequest: NSURLRequest
  let promise: Promise<Wave>

  // MARK: - Initialization

  init(mock: Mock, URLRequest: NSURLRequest, promise: Promise<Wave>) {
    self.mock = mock
    self.URLRequest = URLRequest
    self.promise = promise
  }

  // MARK: - NetworkTaskRunning

  func run() -> Ride {
    process(mock.data, response: mock.response, error: mock.error)
    return Ride(promise: promise)
  }
}
