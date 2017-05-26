import Foundation

final class MockOperation: ConcurrentOperation, ResponseHandler {

  let mock: Mock
  let urlRequest: URLRequest
  let delay: TimeInterval
  var ride: Ride

  // MARK: - Initialization

  init(mock: Mock, urlRequest: URLRequest, delay: TimeInterval = 0.0, ride: Ride) {
    self.mock = mock
    self.urlRequest = urlRequest
    self.delay = delay
    self.ride = ride
  }

  // MARK: - Operation

  override func execute() {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when) { [weak self] in
      self?.handle(data: self?.mock.data, urlResponse: self?.mock.httpResponse, error: self?.mock.error)
      self?.state = .Finished
    }
  }

  override func cancel() {
    super.cancel()
  }
}
