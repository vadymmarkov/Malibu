import Foundation
import When

public final class Ride: Promise<Response> {

  public var operation: Operation?

  public init(operation: Operation? = nil) {
    self.operation = operation
    super.init()
  }

  public func cancel() {
    operation?.cancel()
    operation = nil
  }
}
