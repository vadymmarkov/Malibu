import Foundation
import When
@testable import Malibu

// MARK: - Endpoint

enum TestEndpoint: Endpoint {
  case fetchPosts
  case showPost(id: Int)
  case createPost(title: String)
  case replacePost(id: Int, title: String)
  case updatePost(id: Int, title: String)
  case deletePost(id: Int)
  case head

  static var baseUrl: URLStringConvertible = "http://myrestservice.com"
  static var headers: [String: String] = [:]
  static var sessionConfiguration: SessionConfiguration = .default

  var request: Request {
    switch self {
    case .fetchPosts:
      return Request.get(resource: "posts")
    case .showPost(let id):
      return Request.get(resource: "posts:\(id)", headers: ["key": "value"])
    case .createPost(let title):
      return Request.post(resource: "posts", parameters: ["title": title], headers: ["key": "value"])
    case .replacePost(let id, let title):
      return Request.put(resource: "posts\(id)", parameters: ["title": title], headers: ["key": "value"])
    case .updatePost(let id, let title):
      return Request.patch(resource: "posts\(id)", parameters: ["title": title], headers: ["key": "value"])
    case .deletePost(let id):
      return Request.delete(resource: "posts\(id)")
    case .head:
      return Request.head(resource: "posts")
    }
  }
}


// MARK: - Tasks

class TestResponseHandler: ResponseHandler {
  let urlRequest: URLRequest
  let ride: Ride
  let data = "test".data(using: String.Encoding.utf32)
  let response: HTTPURLResponse

  // MARK: - Initialization

  init() {
    urlRequest = try! TestEndpoint.showPost(id: 1).request.toUrlRequest()
    ride = Ride()
    response = HTTPURLResponse(url: urlRequest.url!, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)!
  }
}
