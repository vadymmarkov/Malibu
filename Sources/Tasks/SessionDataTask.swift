import Foundation
import When

class SessionDataTask: NetworkTaskRunning {
  
  var URLRequest: NSURLRequest
  var promise: Promise<NetworkResult>
  var session: NSURLSession
  
  // MARK: - Initialization
  
  init(session: NSURLSession, URLRequest: NSURLRequest, promise: Promise<NetworkResult>) {
    self.session = session
    self.URLRequest = URLRequest
    self.promise = promise
  }
  
  // MARK: - NetworkTaskRunning
  
  func run() {
    session.dataTaskWithRequest(URLRequest, completionHandler: process).resume()
  }
}
