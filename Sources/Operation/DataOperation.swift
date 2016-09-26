import Foundation

class DataOperation: ConcurrentOperation, ResponseHandler {

  let session: NSURLSession
  let URLRequest: NSURLRequest
  var ride: Ride
  private var task: NSURLSessionDataTask?

  // MARK: - Initialization

  init(session: NSURLSession, URLRequest: NSURLRequest, ride: Ride) {
    self.session = session
    self.URLRequest = URLRequest
    self.ride = ride
  }

  // MARK: - Operation

  override func execute() {
    task = session.dataTaskWithRequest(URLRequest) { [weak self] (data, response, error) in
      guard let weakSelf = self else {
        return
      }

      weakSelf.handle(data, response: response, error: error)

      self?.state = .Finished
    }

    task?.resume()
  }

  override func cancel() {
    super.cancel()
    task?.cancel()
  }
}
