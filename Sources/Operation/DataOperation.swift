import Foundation

final class DataOperation: ConcurrentOperation {
  private let session: URLSession
  private let urlRequest: URLRequest
  private var task: URLSessionDataTask?

  // MARK: - Initialization

  init(session: URLSession, urlRequest: URLRequest) {
    self.session = session
    self.urlRequest = urlRequest
  }

  // MARK: - Operation

  override func execute() {
    task = session.dataTask(with: urlRequest, completionHandler: { [weak self] (data, urlResponse, error) in
      self?.handleResponse?(data, urlResponse, error)
      self?.state = .Finished
    })

    task?.resume()
  }

  override func cancel() {
    super.cancel()
    task?.cancel()
  }
}
