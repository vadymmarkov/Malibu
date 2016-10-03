import Foundation
import When

public protocol Validating {
  func validate(_ result: Wave) throws
}
