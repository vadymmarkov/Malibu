import Foundation
import When

class SessionDataTask: TaskRunning {

  var session: NSURLSession
  var URLRequest: NSURLRequest
  var ride: Ride

  // MARK: - Initialization

  init(session: NSURLSession, URLRequest: NSURLRequest, ride: Ride) {
    self.session = session
    self.URLRequest = URLRequest
    self.ride = ride
  }

  // MARK: - NetworkTaskRunning

  func run() {
    let task = session.dataTaskWithRequest(URLRequest, completionHandler: process)
    task.resume()

    ride.task = task
  }
}
