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

  init(parameters: [String: AnyObject] = [:], headers: [String: String] = [:]) {
    message.parameters = parameters
    message.headers = headers
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
  let promise: Promise<Wave>
  let data = "test".dataUsingEncoding(NSUTF32StringEncoding)
  let response: NSHTTPURLResponse

  // MARK: - Initialization

  init() {
    URLRequest = try! GETRequest().toURLRequest()
    promise = Promise<Wave>()
    response = NSHTTPURLResponse(URL: URLRequest.URL!, statusCode: 200, HTTPVersion: "HTTP/2.0", headerFields: nil)!
  }

  // MARK: - NetworkTaskRunning

  func run() -> Ride {
    process(data, response: response, error: nil)
    return Ride(promise: promise)
  }
}
