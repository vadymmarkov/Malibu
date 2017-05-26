@testable import Malibu
import When
import Quick
import Nimble

class ResponseSpec: QuickSpec {

  override func spec() {
    describe("Response") {
      let url = URL(string: "http://api.loc")!
      let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)!
      var request: URLRequest!
      var data: Data!

      beforeEach {
        request = URLRequest(url: URL(string: "http://api.loc")!)
        data = try! JSONSerialization.data(withJSONObject: [["name": "Taylor"]],
          options: JSONSerialization.WritingOptions())
      }

      describe("#init") {
        it("sets data, request and response parameters to instance vars") {
          let result = Response(data: data, request: request, response: response)

          expect(result.data).to(equal(data))
          expect(result.request).to(equal(request))
          expect(result.response).to(equal(response))
        }
      }
    }
  }
}
