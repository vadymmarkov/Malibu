import Foundation
import When

public class Ride: Promise<Wave> {

  public var operation: NSOperation?

  public init(operation: NSOperation? = nil) {
    self.operation = operation
    super.init()
  }

  public func cancel() {
    operation?.cancel()
    operation = nil
  }
}
