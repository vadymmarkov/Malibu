@testable import Malibu
import Quick
import Nimble

class StatusCodeValidatorSpec: QuickSpec {

  override func spec() {
    describe("StatusCodeValidator") {
      let URL = NSURL(string: "http://hyper.no")!
      var validator: StatusCodeValidator<[Int]>!

      describe("#validate") {
        beforeEach {
          validator = StatusCodeValidator(statusCodes: [200])
        }

        context("when response has expected status code") {
          it("does not throw an error") {
            let HTTPResponse = NSHTTPURLResponse(URL: URL, statusCode: 200,
              HTTPVersion: "HTTP/2.0", headerFields: nil)!

            expect{ try validator.validate(HTTPResponse) }.toNot(throwError())
          }
        }

        context("when response has not expected status code") {
          it("throws an error") {
            let HTTPResponse = NSHTTPURLResponse(URL: URL, statusCode: 404,
              HTTPVersion: "HTTP/2.0", headerFields: nil)!

            expect{ try validator.validate(HTTPResponse) }.to(throwError())
          }
        }
      }
    }
  }
}
