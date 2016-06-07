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

class TestNetworkTask: TaskRunning {
  let URLRequest: NSURLRequest
  let ride: Ride
  let data = "test".dataUsingEncoding(NSUTF32StringEncoding)
  let response: NSHTTPURLResponse

  // MARK: - Initialization

  init() {
    URLRequest = try! GETRequest().toURLRequest()
    ride = Ride()
    response = NSHTTPURLResponse(URL: URLRequest.URL!, statusCode: 200, HTTPVersion: "HTTP/2.0", headerFields: nil)!
  }

  // MARK: - NetworkTaskRunning

  func run() {
    process(data, response: response, error: nil)
  }
}
