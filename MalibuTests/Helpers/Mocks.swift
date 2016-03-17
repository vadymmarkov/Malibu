import Foundation
import When
@testable import Malibu

struct TestRequest: Requestable {
  var message = Message(resource: "http://hyper.no")
}

class TestNetworkTask: NetworkTaskRunning {
  let URLRequest: NSURLRequest
  let promise: Promise<NetworkResult>
  let data = "test".dataUsingEncoding(NSUTF32StringEncoding)
  let response: NSHTTPURLResponse

  // MARK: - Initialization

  init() {
    URLRequest = try! TestRequest().toURLRequest(.GET)
    promise = Promise<NetworkResult>()
    response = NSHTTPURLResponse(URL: URLRequest.URL!, statusCode: 200, HTTPVersion: "HTTP/2.0", headerFields: nil)!
  }

  // MARK: - NetworkTaskRunning

  func run() {
    process(data, response: response, error: nil)
  }
}
