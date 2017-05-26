import Foundation
import When

public final class Response: Equatable {

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

public func == (lhs: Response, rhs: Response) -> Bool {
  return lhs.data == rhs.data
    && lhs.request == rhs.request
    && lhs.response == rhs.response
}
