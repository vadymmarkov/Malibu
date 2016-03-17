import Foundation
import When

class MockDataTask: NetworkTaskRunning {
  
  let mock: MockRequest
  let URLRequest: NSURLRequest
  let promise: Promise<NetworkResult>
  
  // MARK: - Initialization
  
  init(URLRequest: NSURLRequest, promise: Promise<NetworkResult>, mock: MockRequest) {
    self.URLRequest = URLRequest
    self.promise = promise
    self.mock = mock
  }
  
  // MARK: - NetworkTaskRunning
  
  func run() {
    process(mock.data, response: mock.response, error: mock.error)
  }
}
