import Foundation

final class DataOperation: ConcurrentOperation, ResponseHandler {

  let session: URLSession
  let urlRequest: URLRequest
  var ride: Ride
  fileprivate var task: URLSessionDataTask?

  // MARK: - Initialization

  init(session: URLSession, urlRequest: URLRequest, ride: Ride) {
    self.session = session
    self.urlRequest = urlRequest
    self.ride = ride
  }

  // MARK: - Operation

  override func execute() {
    task = session.dataTask(with: urlRequest, completionHandler: { [weak self] (data, response, error) in
      guard let weakSelf = self else {
        return
      }

      weakSelf.handle(data: data, response: response, error: error)

      self?.state = .Finished
    }) 

    task?.resume()
  }

  override func cancel() {
    super.cancel()
    task?.cancel()
  }
}
