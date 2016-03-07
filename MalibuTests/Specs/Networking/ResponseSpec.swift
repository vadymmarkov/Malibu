@testable import Malibu
import Quick
import Nimble

class ResponseSpec: QuickSpec {

  static let URL = NSURL(string: "http://hyper.no")!
  static let HTTPResponse = NSHTTPURLResponse(URL: URL, statusCode: 200,
    HTTPVersion: "HTTP/2.0", headerFields: nil)!
  static let failedHTTPResponse = NSHTTPURLResponse(URL: URL, statusCode: 404,
    HTTPVersion: "HTTP/2.0", headerFields: nil)!

  override func spec() {
    describe("Response") {
      var response: Response<NSData>!
      let URL = NSURL(string: "http://hyper.no")!
      var request: NSURLRequest!
      var data: NSData!

      // MARK: - Helpers

      func testFailedResponse(validationResponse: Response<NSData>) {
        let expectation = self.expectationWithDescription("Validation response failure")

        response.response = ResponseSpec.HTTPResponse

        validationResponse.fail({ error in
          expect(error as! Error == Error.NoDataInResponse).to(beTrue())
          expectation.fulfill()
        })

        response.reject(Error.NoDataInResponse)

        self.waitForExpectationsWithTimeout(4.0, handler:nil)
      }

      func testFailedValidation(validationResponse: Response<NSData>, error: Error, HTTPResponse: NSHTTPURLResponse = ResponseSpec.HTTPResponse) {
        let expectation = self.expectationWithDescription("Validation response failure")

        response.response = HTTPResponse

        validationResponse.fail({ validationError in
          expect(validationError as! Error == error).to(beTrue())
          expectation.fulfill()
        })

        response.resolve(data)

        self.waitForExpectationsWithTimeout(4.0, handler:nil)
      }

      func testSucceededValidation(validationResponse: Response<NSData>, HTTPResponse: NSHTTPURLResponse = ResponseSpec.HTTPResponse) {
        let expectation = self.expectationWithDescription("Validation response success")

        response.response = HTTPResponse

        validationResponse.done({ result in
          expect(result).to(equal(result))
          expectation.fulfill()
        })

        response.resolve(data)

        self.waitForExpectationsWithTimeout(4.0, handler:nil)
      }

      // MARK: - Specs

      beforeEach {
        response = Response()
        request = NSURLRequest(URL: NSURL(string: "http://hyper.no")!)
        data = try! NSJSONSerialization.dataWithJSONObject([["name": "Taylor"]],
          options: NSJSONWritingOptions())
      }

      describe("#init") {
        it("sets request and response values to nil by default") {
          response = Response()

          expect(response.request).to(beNil())
          expect(response.response).to(beNil())
        }

        it("sets request and response parameters to instance vars") {
          response = Response(request: request, response: ResponseSpec.HTTPResponse)

          expect(response.request).to(equal(request))
          expect(response.response).to(equal(ResponseSpec.HTTPResponse))
        }
      }

      describe("#validate:") {
        let validator = StatusCodeValidator(statusCodes: [200])
        var validationResponse: Response<NSData>!

        beforeEach {
          validationResponse = response.validate(validator)
        }

        context("when response is rejected") {
          it("rejects validation response with an error") {
            testFailedResponse(validationResponse)
          }
        }

        context("when response is resolved and validation fails") {
          it("rejects validation response with an error") {
            testFailedValidation(validationResponse, error: Error.UnacceptableStatusCode(404),
              HTTPResponse: ResponseSpec.failedHTTPResponse)
          }
        }

        context("when response is resolved and validation succeeded") {
          it("resolves validation response with a result") {
            testSucceededValidation(validationResponse)
          }
        }
      }

      describe("#validate:statusCodes") {
        var validationResponse: Response<NSData>!

        beforeEach {
          validationResponse = response.validate(statusCodes: [200])
        }

        context("when response is rejected") {
          it("rejects validation response with an error") {
            testFailedResponse(validationResponse)
          }
        }

        context("when response is resolved and validation fails") {
          it("rejects validation response with an error") {
            testFailedValidation(validationResponse, error: Error.UnacceptableStatusCode(404),
              HTTPResponse: ResponseSpec.failedHTTPResponse)
          }
        }

        context("when response is resolved and validation succeeded") {
          it("resolves validation response with a result") {
            testSucceededValidation(validationResponse)
          }
        }
      }

      describe("#validate:contentTypes") {
        var validationResponse: Response<NSData>!

        beforeEach {
          validationResponse = response.validate(contentTypes: ["application/json; charset=utf-8"])
        }

        context("when response is rejected") {
          it("rejects validation response with an error") {
            testFailedResponse(validationResponse)
          }
        }

        context("when response is resolved and validation fails") {
          it("rejects validation response with an error") {
            let HTTPResponse = NSHTTPURLResponse(URL: URL, MIMEType: "text/html; charset=utf-8",
              expectedContentLength: 100, textEncodingName: nil)

            testFailedValidation(validationResponse,
              error: Error.UnacceptableContentType("text/html; charset=utf-8"),
              HTTPResponse: HTTPResponse)
          }
        }

        context("when response is resolved and validation succeeded") {
          it("resolves validation response with a result") {
            let HTTPResponse = NSHTTPURLResponse(URL: URL, MIMEType: "application/json; charset=utf-8",
              expectedContentLength: 100, textEncodingName: nil)

            testSucceededValidation(validationResponse, HTTPResponse: HTTPResponse)
          }
        }
      }

      describe("#validate") {
        var validationResponse: Response<NSData>!

        context("with no accept header in the request") {
          beforeEach {
            validationResponse = response.validate()
          }

          context("when response is rejected") {
            it("rejects validation response with an error") {
              testFailedResponse(validationResponse)
            }
          }

          context("when response is resolved and validation fails") {
            it("rejects validation response with an error") {
              testFailedValidation(validationResponse, error: Error.UnacceptableStatusCode(404),
                HTTPResponse: ResponseSpec.failedHTTPResponse)
            }
          }

          context("when response is resolved and validation succeeded") {
            it("resolves validation response with a result") {
              testSucceededValidation(validationResponse, HTTPResponse: ResponseSpec.HTTPResponse)
            }
          }
        }

        context("with accept header in the request") {
          beforeEach {
            let request = NSMutableURLRequest(URL: URL)
            request.addValue("text/html; charset=utf-8", forHTTPHeaderField: "Accept")
            response.request = request

            validationResponse = response.validate()
          }

          context("when response is rejected") {
            it("rejects validation response with an error") {
              testFailedResponse(validationResponse)
            }
          }

          context("when response is resolved and validation fails") {
            it("rejects validation response with an error") {
              testFailedValidation(validationResponse, error: Error.UnacceptableStatusCode(404),
                HTTPResponse: ResponseSpec.failedHTTPResponse)
            }
          }

          context("when response is resolved and validation succeeded") {
            it("resolves validation response with a result") {
              let HTTPResponse = NSHTTPURLResponse(URL: URL, statusCode: 200,
                HTTPVersion: "HTTP/2.0", headerFields: nil)!
              HTTPResponse.setValue("text/html; charset=utf-8", forKey: "MIMEType")

              testSucceededValidation(validationResponse, HTTPResponse: HTTPResponse)
            }
          }
        }
      }

      describe("#toJSONArray") {
        context("when response is rejected") {
          it("rejects validation response with an error") {
            //testFailedResponse(validationResponse)
          }
        }
      }
    }
  }
}
