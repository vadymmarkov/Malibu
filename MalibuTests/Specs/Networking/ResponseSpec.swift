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

      describe("#validate:") {
        let validator = StatusCodeValidator(statusCodes: [200])
        var validationResponse: Response<String>!

        beforeEach {
          validationResponse = response.validate(validator)
        }

        context("when response is rejected") {
          it("rejects validation response with an error") {
            let expectation = self.expectationWithDescription("Validation response failure")

            validationResponse.fail({ error in
              expect(error as! Error == Error.NoDataInResponse).to(beTrue())
              expectation.fulfill()
            })

            response.reject(Error.NoDataInResponse)

            self.waitForExpectationsWithTimeout(2.0, handler:nil)
          }
        }

        context("when response is resolved and validation fails") {
          it("rejects validation response with an error") {
            let expectation = self.expectationWithDescription("Validation response failure")

            response.response = NSHTTPURLResponse(URL: URL, statusCode: 401,
              HTTPVersion: "HTTP/2.0", headerFields: nil)

            validationResponse.fail({ error in
              expect(error as! Error == Error.UnacceptableStatusCode(401)).to(beTrue())
              expectation.fulfill()
            })

            response.resolve("Success!")

            self.waitForExpectationsWithTimeout(2.0, handler:nil)
          }
        }

        context("when response is resolved and validation succeeded") {
          it("resolves validation response with a result") {
            let expectation = self.expectationWithDescription("Validation response success")
            let result = "Success!"

            response.response = NSHTTPURLResponse(URL: URL, statusCode: 200,
              HTTPVersion: "HTTP/2.0", headerFields: nil)

            validationResponse.done({ result in
              expect(result).to(equal(result))
              expectation.fulfill()
            })

            response.resolve(result)

            self.waitForExpectationsWithTimeout(2.0, handler:nil)
          }
        }
      }

      describe("#validate:statusCodes") {
        var validationResponse: Response<String>!

        beforeEach {
          validationResponse = response.validate(statusCodes: [200])
        }

        context("when response is resolved and validation succeeded") {
          it("resolves validation response with a result") {
            let expectation = self.expectationWithDescription("Validation response success")
            let result = "Success!"

            response.response = NSHTTPURLResponse(URL: URL, statusCode: 200,
              HTTPVersion: "HTTP/2.0", headerFields: nil)

            validationResponse.done({ result in
              expect(result).to(equal(result))
              expectation.fulfill()
            })

            response.resolve(result)

            self.waitForExpectationsWithTimeout(2.0, handler:nil)
          }
        }
      }

      describe("#validate:contentTypes") {
        var validationResponse: Response<String>!

        beforeEach {
          validationResponse = response.validate(contentTypes: ["application/json; charset=utf-8"])
        }

        context("when response is resolved and validation succeeded") {
          it("resolves validation response with a result") {
            let expectation = self.expectationWithDescription("Validation response success")
            let result = "Success!"

            response.response = NSHTTPURLResponse(URL: URL, MIMEType: "application/json; charset=utf-8",
              expectedContentLength: 100, textEncodingName: nil)

            validationResponse.done({ result in
              expect(result).to(equal(result))
              expectation.fulfill()
            })

            response.resolve(result)

            self.waitForExpectationsWithTimeout(2.0, handler:nil)
          }
        }
      }
    }
  }
}
