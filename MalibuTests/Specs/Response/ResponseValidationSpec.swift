@testable import Malibu
import When
import Quick
import Nimble

class ResponseValidationSpec: QuickSpec, NetworkPromiseSpec {

  var networkPromise: Ride!
  var request: URLRequest!
  var data: Data!

  override func spec() {
    describe("ResponseValidation") {
      let url = URL(string: "http://api.loc")!
      let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)!
      let failedResponse = HTTPURLResponse(url: url, statusCode: 404,
                                           httpVersion: "HTTP/2.0", headerFields: nil)!

      // MARK: - Specs

      beforeEach {
        self.networkPromise = Ride()
        self.request = URLRequest(url: URL(string: "http://api.loc")!)
        self.data = try! JSONSerialization.data(withJSONObject: [["name": "Taylor"]],
          options: JSONSerialization.WritingOptions())
      }

      describe("#validate:using") {
        let validator = StatusCodeValidator(statusCodes: [200])
        var promise: Promise<Response>!

        beforeEach {
          promise = self.networkPromise.validate(using: validator)
        }

        context("when response is rejected") {
          it("rejects promise with an error") {
            self.testFailedResponse(promise)
          }
        }

        context("when response is resolved and validation fails") {
          it("rejects promise with an error") {
            self.testFailedPromise(promise, error: NetworkError.unacceptableStatusCode(404),
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
        var promise: Promise<Response>!

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
            self.testFailedPromise(promise, error: NetworkError.unacceptableStatusCode(404),
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
        var promise: Promise<Response>!

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
            let response = HTTPURLResponse(url: url, mimeType: "text/html; charset=utf-8",
              expectedContentLength: 100, textEncodingName: nil)

            self.testFailedPromise(promise,
              error: NetworkError.unacceptableContentType("text/html; charset=utf-8"),
              response: response)
          }
        }

        context("when response is resolved and validation succeeded") {
          it("resolves promise with a result") {
            let response = HTTPURLResponse(url: url, mimeType: "application/json; charset=utf-8",
              expectedContentLength: 100, textEncodingName: nil)
            self.testSucceededPromise(promise, response: response)
          }
        }
      }

      describe("#validate") {
        var promise: Promise<Response>!

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
              self.testFailedPromise(promise, error: NetworkError.unacceptableStatusCode(404),
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
          var promise: Promise<Response>!

          beforeEach {
            var request = URLRequest(url: url)
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
              self.testFailedPromise(promise, error: NetworkError.unacceptableStatusCode(404),
                response: failedResponse)
            }
          }

          context("when response is resolved and validation succeeded") {
            it("resolves promise with a result") {
              let HTTPResponse = HTTPURLResponse(url: url, statusCode: 200,
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
