import Foundation

final class MockOperation: ConcurrentOperation {
  private let mock: Mock
  private let delay: TimeInterval

  // MARK: - Initialization

  init(mock: Mock, delay: TimeInterval = 0.0) {
    self.mock = mock
    self.delay = delay
  }

  // MARK: - Operation

  override func execute() {
    do {
      let urlRequest = try extractUrlRequest()
      let when = DispatchTime.now() + delay
      DispatchQueue.main.asyncAfter(deadline: when) { [weak self] in
        self?.handleResponse?(urlRequest, self?.mock.data, self?.mock.httpResponse, self?.mock.error)
        self?.state = .Finished
      }
    } catch {
      handleResponse?(nil, nil, nil, error)
    }
  }

  override func cancel() {
    super.cancel()
  }
}
