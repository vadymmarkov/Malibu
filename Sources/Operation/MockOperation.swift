import Foundation

final class MockOperation: ConcurrentOperation {
  private let mock: Mock
  private let urlRequest: URLRequest
  private let delay: TimeInterval

  // MARK: - Initialization

  init(mock: Mock, urlRequest: URLRequest, delay: TimeInterval = 0.0) {
    self.mock = mock
    self.urlRequest = urlRequest
    self.delay = delay
  }

  // MARK: - Operation

  override func execute() {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when) { [weak self] in
      self?.handleResponse?(self?.mock.data, self?.mock.httpResponse, self?.mock.error)
      self?.state = .Finished
    }
  }

  override func cancel() {
    super.cancel()
  }
}
