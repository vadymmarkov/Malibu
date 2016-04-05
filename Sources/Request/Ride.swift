import Foundation
import When

public class Ride {

  public var promise: Promise<NetworkResult>
  public var task: NSURLSessionTask?

  public init(promise: Promise<NetworkResult>, task: NSURLSessionTask? = nil) {
    self.promise = promise
    self.task = task
  }

  public func cancel() {
    task?.cancel()
    task = nil
  }
}
