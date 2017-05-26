import Foundation
import When

public final class Ride: Promise<Response> {
  weak var operation: Operation?

  public func cancel() {
    operation?.cancel()
    operation = nil
  }
}
