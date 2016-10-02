import Foundation

class MockOperation: ConcurrentOperation, ResponseHandler {

  let mock: Mock
  let urlRequest: URLRequest
  var ride: Ride

  // MARK: - Initialization

  init(mock: Mock, urlRequest: URLRequest, ride: Ride) {
    self.mock = mock
    self.urlRequest = urlRequest
    self.ride = ride
  }

  // MARK: - Operation

  override func execute() {
    DispatchQueue.main.asyncAfter(
      deadline: DispatchTime.now() + Double(Int64(mock.delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { [weak self] in
        self?.handle(self?.mock.data, response: self?.mock.response, error: self?.mock.error)
        self?.state = .Finished
    }
  }

  override func cancel() {
    super.cancel()
  }
}
