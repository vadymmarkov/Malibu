import Foundation
import When

class MockDataOperationBuilder: OperationBuilder {

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

  func build() -> NSOperation {
    process(mock.data, response: mock.response, error: mock.error)
  }
}
