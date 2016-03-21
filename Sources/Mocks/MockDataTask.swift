import Foundation
import When

class MockDataTask: NetworkTaskRunning {

  let mock: Mock
  let URLRequest: NSURLRequest
  let promise: Promise<NetworkResult>

  // MARK: - Initialization

  init(mock: Mock, URLRequest: NSURLRequest, promise: Promise<NetworkResult>) {
    self.mock = mock
    self.URLRequest = URLRequest
    self.promise = promise
  }

  // MARK: - NetworkTaskRunning

  func run() {
    process(mock.data, response: mock.response, error: mock.error)
  }
}
