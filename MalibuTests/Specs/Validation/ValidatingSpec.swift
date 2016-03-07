@testable import Malibu
import Quick
import Nimble

class ValidatingSpec: QuickSpec {

  override func spec() {
    describe("Validating") {
      describe(".attachTo") {
        let URL = NSURL(string: "http://hyper.no")!
        var response: Response<String>!
        var validationResponse: Response<String>!

        beforeEach {
          let request = NSURLRequest(URL: URL)

          response = Response(request: request)
          validationResponse = StatusCodeValidator(statusCodes: [200]).attachTo(response)
        }

        context("when response is rejected") {
          it("rejects validation response with an error") {
            let HTTPResponse = NSHTTPURLResponse(URL: URL, statusCode: 200,
              HTTPVersion: "HTTP/2.0", headerFields: nil)!
            let expectation = self.expectationWithDescription("Validation response failure")

            response.response = HTTPResponse

            validationResponse.fail({ error in
              expect(error as! Error == Error.NoDataInResponse).to(beTrue())
              expect(validationResponse.request).to(equal(response.request))
              expect(validationResponse.response).to(equal(response.response))
              expectation.fulfill()
            })

            response.reject(Error.NoDataInResponse)

            self.waitForExpectationsWithTimeout(4.0, handler:nil)
          }
        }

        context("when response is resolved and validation fails") {
          it("rejects validation response with an error") {
            let HTTPResponse = NSHTTPURLResponse(URL: URL, statusCode: 404,
              HTTPVersion: "HTTP/2.0", headerFields: nil)!
            let expectation = self.expectationWithDescription("Validation response failure")

            response.response = HTTPResponse

            validationResponse.fail({ validationError in
              expect(validationError as! Error == Error.UnacceptableStatusCode(404)).to(beTrue())
              expect(validationResponse.request).to(equal(response.request))
              expect(validationResponse.response).to(equal(response.response))
              expectation.fulfill()
            })

            response.resolve("Success!")

            self.waitForExpectationsWithTimeout(4.0, handler:nil)
          }
        }

        context("when response is resolved and validation succeeded") {
          it("resolves validation response with a result") {
            let HTTPResponse = NSHTTPURLResponse(URL: URL, statusCode: 200,
              HTTPVersion: "HTTP/2.0", headerFields: nil)!
            let expectation = self.expectationWithDescription("Validation response success")
            let result = "Success!"

            response.response = HTTPResponse

            validationResponse.done({ result in
              expect(result).to(equal(result))
              expect(validationResponse.request).to(equal(response.request))
              expect(validationResponse.response).to(equal(response.response))
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
