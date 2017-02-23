import Foundation
import When
@testable import Malibu

// MARK: - Service

enum TestService: RequestConvertible {
  case fetchPosts
  case showPost(id: Int)
  case createPost(title: String)
  case replacePost(id: Int, title: String)
  case updatePost(id: Int, title: String)
  case deletePost(id: Int)
  case head

  static var baseUrl: URLStringConvertible = "http://api.loc"
  static var headers: [String: String] = [:]

  var request: Request {
    switch self {
    case .fetchPosts:
      return Request.get("posts")
    case .showPost(let id):
      return Request.get("posts/\(id)")
    case .createPost(let title):
      return Request.post("posts", parameters: ["title": title])
    case .replacePost(let id, let title):
      return Request.put("posts/\(id)", parameters: ["title": title])
    case .updatePost(let id, let title):
      return Request.patch("posts/\(id)", parameters: ["title": title])
    case .deletePost(let id):
      return Request.delete("posts/\(id)")
    case .head:
      return Request.head("posts")
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
    urlRequest = try! TestService.showPost(id: 1).request.toUrlRequest()
    ride = Ride()
    response = HTTPURLResponse(url: urlRequest.url!, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)!
  }
}
