@testable import Malibu
import When
import Quick
import Nimble

class WaveValidationSpec: QuickSpec, NetworkPromiseSpec {

  var networkPromise: Ride!
  var request: URLRequest!
  var data: Data!

  override func spec() {
    describe("WaveValidation") {
      let URL = Foundation.URL(string: "http://hyper.no")!
      let response = HTTPURLResponse(url: URL, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)!
      let failedResponse = HTTPURLResponse(url: URL, statusCode: 404, httpVersion: "HTTP/2.0", headerFields: nil)!

      // MARK: - Specs

      beforeEach {
        self.networkPromise = Ride()
        self.request = URLRequest(url: Foundation.URL(string: "http://hyper.no")!)
        self.data = try! JSONSerialization.data(withJSONObject: [["name": "Taylor"]],
          options: JSONSerialization.WritingOptions())
      }

      describe("#validate:validator") {
        let validator = StatusCodeValidator(statusCodes: [200])
        var promise: Promise<Wave>!

        beforeEach {
          promise = self.networkPromise.validate(validator)
        }

        context("when response is rejected") {
          it("rejects promise with an error") {
            self.testFailedResponse(promise)
          }
        }

        context("when response is resolved and validation fails") {
          it("rejects promise with an error") {
            self.testFailedPromise(promise, error: Error.UnacceptableStatusCode(404),
              response: failedResponse)
          }
        }

        context("when response is resolved and validation succeeded") {
          it("resolves promise with a result") {
            self.testSucceededPromise(promise, response: response)
          }
        }
      }

      describe("#validate:statusCodes") {
        var promise: Promise<Wave>!

        beforeEach {
          promise = self.networkPromise.validate(statusCodes: [200])
        }

        context("when response is rejected") {
          it("rejects promise with an error") {
            self.testFailedResponse(promise)
          }
        }

        context("when response is resolved and validation fails") {
          it("rejects promise with an error") {
            self.testFailedPromise(promise, error: Error.UnacceptableStatusCode(404),
              response: failedResponse)
          }
        }

        context("when response is resolved and validation succeeded") {
          it("resolves promise with a result") {
            self.testSucceededPromise(promise, response: response)
          }
        }
      }

      describe("#validate:contentTypes") {
        var promise: Promise<Wave>!

        beforeEach {
          promise = self.networkPromise.validate(contentTypes: ["application/json; charset=utf-8"])
        }

        context("when response is rejected") {
          it("rejects promise with an error") {
            self.testFailedResponse(promise)
          }
        }

        context("when response is resolved and validation fails") {
          it("rejects promise with an error") {
            let response = HTTPURLResponse(url: URL, mimeType: "text/html; charset=utf-8",
              expectedContentLength: 100, textEncodingName: nil)

            self.testFailedPromise(promise,
              error: Error.UnacceptableContentType("text/html; charset=utf-8"),
              response: response)
          }
        }

        context("when response is resolved and validation succeeded") {
          it("resolves promise with a result") {
            let response = HTTPURLResponse(url: URL, mimeType: "application/json; charset=utf-8",
              expectedContentLength: 100, textEncodingName: nil)
            self.testSucceededPromise(promise, response: response)
          }
        }
      }

      describe("#validate") {
        var promise: Promise<Wave>!

        context("with no accept header in the request") {
          beforeEach {
            promise = self.networkPromise.validate()
          }

          context("when response is rejected") {
            it("rejects promise with an error") {
              self.testFailedResponse(promise)
            }
          }

          context("when response is resolved and validation fails") {
            it("rejects promise with an error") {
              self.testFailedPromise(promise, error: Error.UnacceptableStatusCode(404),
                response: failedResponse)
            }
          }

          context("when response is resolved and validation succeeded") {
            it("resolves response with a result") {
              self.testSucceededPromise(promise, response: response)
            }
          }
        }

        context("with accept header in the request") {
          var promise: Promise<Wave>!

          beforeEach {
            let request = NSMutableURLRequest(url: URL)
            request.addValue("text/html; charset=utf-8", forHTTPHeaderField: "Accept")
            promise = self.networkPromise.validate()
          }

          context("when response is rejected") {
            it("rejects promise with an error") {
              self.testFailedResponse(promise)
            }
          }

          context("when response is resolved and validation fails") {
            it("rejects promise with an error") {
              self.testFailedPromise(promise, error: Error.UnacceptableStatusCode(404),
                response: failedResponse)
            }
          }

          context("when response is resolved and validation succeeded") {
            it("resolves promise with a result") {
              let HTTPResponse = HTTPURLResponse(url: URL, statusCode: 200,
                httpVersion: "HTTP/2.0", headerFields: nil)!
              HTTPResponse.setValue("text/html; charset=utf-8", forKey: "MIMEType")

              self.testSucceededPromise(promise, response: response)
            }
          }
        }
      }
    }
  }
}
