@testable import Malibu
import When
import Quick
import Nimble

class NetworkResultSpec: QuickSpec {

  override func spec() {
    describe("NetworkResult") {
      let URL = NSURL(string: "http://hyper.no")!
      let response = NSHTTPURLResponse(URL: URL, statusCode: 200, HTTPVersion: "HTTP/2.0", headerFields: nil)!
      var request: NSURLRequest!
      var data: NSData!

      beforeEach {
        request = NSURLRequest(URL: NSURL(string: "http://hyper.no")!)
        data = try! NSJSONSerialization.dataWithJSONObject([["name": "Taylor"]],
          options: NSJSONWritingOptions())
      }

      describe("#init") {
        it("sets data, request and response parameters to instance vars") {
          let result = NetworkResult(data: data, request: request, response: response)

          expect(result.data).to(equal(data))
          expect(result.request).to(equal(request))
          expect(result.response).to(equal(response))
        }
      }
    }
  }
}
