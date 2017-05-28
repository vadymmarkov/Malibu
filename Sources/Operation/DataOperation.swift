import Foundation

final class DataOperation: ConcurrentOperation {
  private let session: URLSession
  private var task: URLSessionDataTask?

  // MARK: - Initialization

  init(session: URLSession) {
    self.session = session
  }

  // MARK: - Operation

  override func execute() {
    do {
      let urlRequest = try extractUrlRequest()
      task = session.dataTask(with: urlRequest, completionHandler: { [weak self] (data, urlResponse, error) in
        self?.handleResponse?(urlRequest, data, urlResponse, error)
        self?.state = .Finished
      })

      task?.resume()
    } catch {
      handleResponse?(nil, nil, nil, error)
    }
  }

  override func cancel() {
    super.cancel()
    task?.cancel()
  }
}
