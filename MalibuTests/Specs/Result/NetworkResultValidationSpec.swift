@testable import Malibu
import When
import Quick
import Nimble

class NetworkResultValidationSpec: QuickSpec, NetworkPromiseSpec {

  var networkPromise: Promise<NetworkResult>!
  var request: NSURLRequest!
  var data: NSData!

  override func spec() {
    describe("NetworkResultValidation") {
      let URL = NSURL(string: "http://hyper.no")!
      let response = NSHTTPURLResponse(URL: URL, statusCode: 200, HTTPVersion: "HTTP/2.0", headerFields: nil)!
      let failedResponse = NSHTTPURLResponse(URL: URL, statusCode: 404, HTTPVersion: "HTTP/2.0", headerFields: nil)!

      // MARK: - Specs

      beforeEach {
        self.networkPromise = Promise<NetworkResult>()
        self.request = NSURLRequest(URL: NSURL(string: "http://hyper.no")!)
        self.data = try! NSJSONSerialization.dataWithJSONObject([["name": "Taylor"]],
          options: NSJSONWritingOptions())
      }

      describe("#init") {
        it("sets data, request and response parameters to instance vars") {
          let result = NetworkResult(data: self.data, request: self.request, response: response)

          expect(result.request).to(equal(self.request))
          expect(result.response).to(equal(response))
        }
      }

      describe("#validate:") {
        let validator = StatusCodeValidator(statusCodes: [200])
        var promise: Promise<NetworkResult>!

        beforeEach {
          promise = self.networkPromise.validate(validator)
        }

        context("when response is rejected") {
          it("rejects validation promise with an error") {
            self.testFailedResponse(promise)
          }
        }

        context("when response is resolved and validation fails") {
          it("rejects validation promise with an error") {
            self.testFailedPromise(promise, error: Error.UnacceptableStatusCode(404),
              response: failedResponse)
          }
        }

        context("when response is resolved and validation succeeded") {
          it("resolves validation response with a result") {
            self.testSucceededPromise(promise, response: response)
          }
        }
      }

      describe("#validate:statusCodes") {
        var promise: Promise<NetworkResult>!

        beforeEach {
          promise = self.networkPromise.validate(statusCodes: [200])
        }

        context("when response is rejected") {
          it("rejects validation promise with an error") {
            self.testFailedResponse(promise)
          }
        }

        context("when response is resolved and validation fails") {
          it("rejects validation promise with an error") {
            self.testFailedPromise(promise, error: Error.UnacceptableStatusCode(404),
              response: failedResponse)
          }
        }

        context("when response is resolved and validation succeeded") {
          it("resolves validation response with a result") {
            self.testSucceededPromise(promise, response: response)
          }
        }
      }

      describe("#validate:contentTypes") {
        var promise: Promise<NetworkResult>!

        beforeEach {
          promise = self.networkPromise.validate(contentTypes: ["application/json; charset=utf-8"])
        }

        context("when response is rejected") {
          it("rejects validation promise with an error") {
            self.testFailedResponse(promise)
          }
        }

        context("when response is resolved and validation fails") {
          it("rejects validation promise with an error") {
            let response = NSHTTPURLResponse(URL: URL, MIMEType: "text/html; charset=utf-8",
              expectedContentLength: 100, textEncodingName: nil)

            self.testFailedPromise(promise,
              error: Error.UnacceptableContentType("text/html; charset=utf-8"),
              response: response)
          }
        }

        context("when response is resolved and validation succeeded") {
          it("resolves validation response with a result") {
            let response = NSHTTPURLResponse(URL: URL, MIMEType: "application/json; charset=utf-8",
              expectedContentLength: 100, textEncodingName: nil)
            self.testSucceededPromise(promise, response: response)
          }
        }
      }

      describe("#validate") {
        var promise: Promise<NetworkResult>!

        context("with no accept header in the request") {
          beforeEach {
            promise = self.networkPromise.validate()
          }

          context("when response is rejected") {
            it("rejects validation promise with an error") {
              self.testFailedResponse(promise)
            }
          }

          context("when response is resolved and validation fails") {
            it("rejects validation promise with an error") {
              self.testFailedPromise(promise, error: Error.UnacceptableStatusCode(404),
                response: failedResponse)
            }
          }

          context("when response is resolved and validation succeeded") {
            it("resolves validation response with a result") {
              self.testSucceededPromise(promise, response: response)
            }
          }
        }

        context("with accept header in the request") {
          var promise: Promise<NetworkResult>!

          beforeEach {
            let request = NSMutableURLRequest(URL: URL)
            request.addValue("text/html; charset=utf-8", forHTTPHeaderField: "Accept")
            promise = self.networkPromise.validate()
          }

          context("when response is rejected") {
            it("rejects validation promise with an error") {
              self.testFailedResponse(promise)
            }
          }

          context("when response is resolved and validation fails") {
            it("rejects validation promise with an error") {
              self.testFailedPromise(promise, error: Error.UnacceptableStatusCode(404),
                response: failedResponse)
            }
          }

          context("when response is resolved and validation succeeded") {
            it("resolves validation response with a result") {
              let HTTPResponse = NSHTTPURLResponse(URL: URL, statusCode: 200,
                HTTPVersion: "HTTP/2.0", headerFields: nil)!
              HTTPResponse.setValue("text/html; charset=utf-8", forKey: "MIMEType")

              self.testSucceededPromise(promise, response: response)
            }
          }
        }
      }
    }
  }
}
