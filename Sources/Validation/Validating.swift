import Foundation
import When

public protocol Validating {
  func validate(_ response: Response) throws
}
