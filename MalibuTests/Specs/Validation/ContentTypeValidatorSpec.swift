@testable import Malibu
import Quick
import Nimble

class ContentTypeValidatorSpec: QuickSpec {

  override func spec() {
    describe("ContentTypeValidator") {
      describe(".validateResponse") {
        let URL = NSURL(string: "http://hyper.no")!
        let contentType = "application/json; charset=utf-8"
        var response: Response<String>!
        var validationResponse: Response<String>!

        beforeEach {
          let request = NSURLRequest(URL: URL)

          response = Response(request: request)
          validationResponse = ContentTypeValidator(
            contentTypes: [contentType]).validate(response)
        }

        context("when response is rejected") {
          it("rejects validation response with an error") {
            let HTTPResponse = NSHTTPURLResponse(URL: URL, MIMEType: contentType,
              expectedContentLength: 10, textEncodingName: nil)
            let expectation = self.expectationWithDescription("Validation response failure")

            response.response = HTTPResponse

            validationResponse.fail({ error in
              expect(error as! Error == Error.NoDataInResponse).to(beTrue())
              expectation.fulfill()
            })

            response.reject(Error.NoDataInResponse)

            self.waitForExpectationsWithTimeout(4.0, handler:nil)
          }
        }

        context("when response is resolved and validation fails") {
          it("rejects validation response with an error") {
            let HTTPResponse = NSHTTPURLResponse(URL: URL, MIMEType: "text/html; charset=utf-8",
              expectedContentLength: 100, textEncodingName: nil)
            let expectation = self.expectationWithDescription("Validation response failure")

            response.response = HTTPResponse

            validationResponse.fail({ validationError in
              expect(validationError as! Error ==
                Error.UnacceptableContentType("text/html; charset=utf-8")).to(beTrue())
              expectation.fulfill()
            })

            response.resolve("Success!")

            self.waitForExpectationsWithTimeout(4.0, handler:nil)
          }
        }

        context("when response is resolved and validation succeeded") {
          it("resolves validation response with a result") {
            let HTTPResponse = NSHTTPURLResponse(URL: URL, MIMEType: contentType,
              expectedContentLength: 10, textEncodingName: nil)
            let expectation = self.expectationWithDescription("Validation response success")
            let result = "Success!"

            response.response = HTTPResponse

            validationResponse.done({ result in
              expect(result).to(equal(result))
              expectation.fulfill()
            })

            response.resolve(result)

            self.waitForExpectationsWithTimeout(4.0, handler:nil)
          }
        }
      }
    }
  }
}
