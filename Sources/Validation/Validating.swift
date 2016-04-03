import Foundation
import When

public protocol Validating {
  func validate(result: NetworkResult) throws
}
