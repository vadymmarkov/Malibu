@testable import Malibu
import Quick
import Nimble

class ResponseSpec: QuickSpec {

  override func spec() {
    describe("Error") {
      var response: Response<String>!
      let URL = NSURL(string: "http://hyper.no")!
      var request: NSURLRequest!
      var HTTPURLResponse: NSHTTPURLResponse!

      beforeEach {
        response = Response()
        request = NSURLRequest(URL: NSURL(string: "http://hyper.no")!)
        HTTPURLResponse = NSHTTPURLResponse(URL: URL, statusCode: 401, HTTPVersion: "HTTP/2.0", headerFields: nil)
      }

      describe("#init") {
        it("sets request and response values to nil by default") {
          response = Response()

          expect(response.request).to(beNil())
          expect(response.response).to(beNil())
        }

        it("sets request and response parameters to instance vars") {
          response = Response(request: request, response: HTTPURLResponse)

          expect(response.request).to(equal(request))
          expect(response.response).to(equal(HTTPURLResponse))
        }
      }
    }
  }
}
