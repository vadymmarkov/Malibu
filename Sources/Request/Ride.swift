import Foundation
import When

public final class Ride: Promise<Wave> {

  public var operation: Operation?

  public init(operation: Operation? = nil) {
    self.operation = operation
    super.init()
  }

  open override func cancel() {
    operation?.cancel()
    operation = nil
  }
}
