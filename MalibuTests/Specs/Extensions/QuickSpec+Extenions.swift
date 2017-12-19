@testable import Malibu
import Quick

extension QuickSpec {
  func makeResponse(statusCode: Int, data: Data = .init()) -> Response {
    let url = URL(string: "http://api.loc")!
    return Response(
      data: data,
      urlRequest: URLRequest(url: url),
      httpUrlResponse: HTTPURLResponse(
        url: url,
        statusCode: statusCode,
        httpVersion: "HTTP/2.0", headerFields: nil)!
    )
  }
}
