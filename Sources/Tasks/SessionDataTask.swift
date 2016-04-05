import Foundation
import When

class SessionDataTask: TaskRunning {

  var session: NSURLSession
  var URLRequest: NSURLRequest
  var promise: Promise<NetworkResult>

  // MARK: - Initialization

  init(session: NSURLSession, URLRequest: NSURLRequest, promise: Promise<NetworkResult>) {
    self.session = session
    self.URLRequest = URLRequest
    self.promise = promise
  }

  // MARK: - NetworkTaskRunning

  func run() -> Ride {
    let task = session.dataTaskWithRequest(URLRequest, completionHandler: process)
    task.resume()

    return Ride(promise: promise, task: task)
  }
}
