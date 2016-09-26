import Foundation

class MockOperation: ConcurrentOperation, ResponseHandler {

  let mock: Mock
  let URLRequest: NSURLRequest
  var ride: Ride

  // MARK: - Initialization

  init(mock: Mock, URLRequest: NSURLRequest, ride: Ride) {
    self.mock = mock
    self.URLRequest = URLRequest
    self.ride = ride
  }

  // MARK: - Operation

  override func execute() {
    dispatch_after(
      dispatch_time(DISPATCH_TIME_NOW, Int64(mock.delay * Double(NSEC_PER_SEC))),
      dispatch_get_main_queue()) { [weak self] in
        self?.handle(self?.mock.data, response: self?.mock.response, error: self?.mock.error)
        self?.state = .Finished
    }
  }

  override func cancel() {
    super.cancel()
  }
}
