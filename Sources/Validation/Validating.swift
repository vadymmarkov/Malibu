import Foundation

public protocol Validating {
  func validate(_ response: Response) throws
}
