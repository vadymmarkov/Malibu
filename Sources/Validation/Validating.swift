import Foundation
import When

public protocol Validating {
  func validate(response: NSHTTPURLResponse) throws
}
