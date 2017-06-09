import Foundation

final class SessionOperation: ConcurrentOperation {
  private let taskType: Request.Task
  private let session: URLSession
  private var task: URLSessionTask?

  // MARK: - Initialization

  init(_ taskType: Request.Task, session: URLSession) {
    self.taskType = taskType
    self.session = session
  }

  // MARK: - Operation

  override func execute() {
    do {
      let urlRequest = try extractUrlRequest()

      switch taskType {
      case .data:
        task = session.dataTask(with: urlRequest) { [weak self] (data, urlResponse, error) in
          self?.handleResponse?(urlRequest, data, urlResponse, error)
          self?.state = .Finished
        }
      case .upload:
        let data = urlRequest.httpBody

        task = session.uploadTask(with: urlRequest, from: data) { [weak self] (data, urlResponse, error) in
          self?.handleResponse?(urlRequest, data, urlResponse, error)
          self?.state = .Finished
        }
      }

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
