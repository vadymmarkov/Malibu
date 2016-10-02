import Foundation
import When

public final class Wave: Equatable {

  public let data: Data
  public let request: URLRequest
  public let response: HTTPURLResponse

  public init(data: Data, request: URLRequest, response: HTTPURLResponse) {
    self.data = data
    self.request = request
    self.response = response
  }
}

// MARK: - Equatable

public func ==(lhs: Wave, rhs: Wave) -> Bool {
  return lhs.data == rhs.data
    && lhs.request == rhs.request
    && lhs.response == rhs.response
}
