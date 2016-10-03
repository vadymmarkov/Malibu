import Foundation

final class MockOperation: ConcurrentOperation, ResponseHandler {

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
    let when = DispatchTime.now() + mock.delay
    DispatchQueue.main.asyncAfter(deadline: when) { [weak self] in
      self?.handle(data: self?.mock.data, response: self?.mock.response, error: self?.mock.error)
      self?.state = .Finished
    }
  }

  override func cancel() {
    super.cancel()
  }
}
