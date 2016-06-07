import Foundation
import When

public class Ride: Promise<Wave> {

  public var task: NSURLSessionTask?

  public init(task: NSURLSessionTask? = nil) {
    self.task = task
    super.init()
  }

  public func cancel() {
    task?.cancel()
    task = nil
  }
}
