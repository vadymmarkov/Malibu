import Foundation
import When

public typealias NetworkPromise = Promise<Response>

public final class Response: Equatable {
  public let data: Data
  public let urlRequest: URLRequest
  public let httpUrlResponse: HTTPURLResponse
  public var statusCode: Int {
    return httpUrlResponse.statusCode
  }

  public init(data: Data, urlRequest: URLRequest, httpUrlResponse: HTTPURLResponse) {
    self.data = data
    self.urlRequest = urlRequest
    self.httpUrlResponse = httpUrlResponse
  }
}

// MARK: - Equatable

public func == (lhs: Response, rhs: Response) -> Bool {
  return lhs.data == rhs.data
    && lhs.urlRequest == rhs.urlRequest
    && lhs.httpUrlResponse == rhs.httpUrlResponse
}
