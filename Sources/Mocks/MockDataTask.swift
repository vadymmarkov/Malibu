import Foundation
import When

class MockDataTask: TaskRunning {

  let mock: Mock
  let URLRequest: NSURLRequest
  let ride: Ride

  // MARK: - Initialization

  init(mock: Mock, URLRequest: NSURLRequest, ride: Ride) {
    self.mock = mock
    self.URLRequest = URLRequest
    self.ride = ride
  }

  // MARK: - NetworkTaskRunning

  func run() {
    process(mock.data, response: mock.response, error: mock.error)
  }
}
