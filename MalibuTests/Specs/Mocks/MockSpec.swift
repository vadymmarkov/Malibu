@testable import Malibu
import Quick
import Nimble
import When

class MockSpec: QuickSpec {

  override func spec() {
    describe("Mock") {
      var mock: Mock!
      let request = TestRequest()
      let response = NSHTTPURLResponse(URL: NSURL(string: "http://hyper.no")!,
        statusCode: 200, HTTPVersion: "HTTP/2.0", headerFields: nil)!
      let data = "test".dataUsingEncoding(NSUTF32StringEncoding)
      let error = Error.NoDataInResponse

      describe("#init") {
        beforeEach {
          mock = Mock(request: request, response: response, data: data, error: error)
        }

        it("sets properties") {
          expect(mock.request.message).to(equal(request.message))
          expect(mock.response).to(equal(response))
          expect(mock.data).to(equal(data))
          expect(mock.error as! Error == error).to(beTrue())
        }
      }
    }
  }
}
