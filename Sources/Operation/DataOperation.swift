import Foundation

public typealias DataTaskCompletion = (NSData?, NSURLResponse?, NSError?) -> Void

class DataOperation: ConcurrentOperation {

  private let session: NSURLSession
  private let request: NSURLRequest
  private let completion: DataTaskCompletion
  private var task: NSURLSessionDataTask?

  init(session: NSURLSession, request: NSURLRequest, completion: DataTaskCompletion) {
    self.session = session
    self.request = request
    self.completion = completion
  }

  override func execute() {
    task = session.dataTaskWithRequest(request) { [weak self] (data, response, error) in
      self?.completion(data, response, error)
      self?.state = .Finished
    }

    task?.resume()
  }

  override func cancel() {
    super.cancel()
    task?.cancel()
  }
}
