import Foundation
import When

public class Ride {

  public var promise: Promise<Wave>
  public var task: NSURLSessionTask?

  public init(promise: Promise<Wave>, task: NSURLSessionTask? = nil) {
    self.promise = promise
    self.task = task
  }

  public func cancel() {
    task?.cancel()
    task = nil
  }
}
