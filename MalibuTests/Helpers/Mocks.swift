import Foundation
import When
@testable import Malibu

// MARK: - Requests

struct GETRequest: GETRequestable {
  var message = Message(resource: "http://hyper.no")

  init(parameters: [String: AnyObject] = [:], headers: [String: String] = [:]) {
    message.parameters = parameters
    message.headers = headers
  }
}

struct POSTRequest: POSTRequestable {
  var message = Message(resource: "http://hyper.no")
  let content: ContentType

  var contentType: ContentType {
    return content
  }

  init(parameters: [String: AnyObject] = [:],
       headers: [String: String] = [:],
       contentType: ContentType = .JSON) {
    message.parameters = parameters
    message.headers = headers
    content = contentType
  }
}

struct PUTRequest: PUTRequestable {
  var message = Message(resource: "http://hyper.no")
}

struct PATCHRequest: PATCHRequestable {
  var message = Message(resource: "http://hyper.no")
}

struct DELETERequest: DELETERequestable {
  var message = Message(resource: "http://hyper.no")
}

struct HEADRequest: HEADRequestable {
  var message = Message(resource: "http://hyper.no")
}

// MARK: - Tasks

class TestResponseHandler: ResponseHandler {
  let urlRequest: URLRequest
  let ride: Ride
  let data = "test".data(using: String.Encoding.utf32)
  let response: HTTPURLResponse

  // MARK: - Initialization

  init() {
    urlRequest = try! GETRequest().toURLRequest()
    ride = Ride()
    response = HTTPURLResponse(url: urlRequest.url!, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)!
  }
}
