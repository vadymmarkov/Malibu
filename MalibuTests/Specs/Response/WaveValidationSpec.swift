@testable import Malibu
import When
import Quick
import Nimble

class WaveValidationSpec: QuickSpec, NetworkPromiseSpec {

  var networkPromise: Promise<Wave>!
  var request: NSURLRequest!
  var data: NSData!

  override func spec() {
    describe("WaveValidation") {
      let URL = NSURL(string: "http://hyper.no")!
      let response = NSHTTPURLResponse(URL: URL, statusCode: 200, HTTPVersion: "HTTP/2.0", headerFields: nil)!
      let failedResponse = NSHTTPURLResponse(URL: URL, statusCode: 404, HTTPVersion: "HTTP/2.0", headerFields: nil)!

      // MARK: - Specs

      beforeEach {
        self.networkPromise = Promise<Wave>()
        self.request = NSURLRequest(URL: NSURL(string: "http://hyper.no")!)
        self.data = try! NSJSONSerialization.dataWithJSONObject([["name": "Taylor"]],
          options: NSJSONWritingOptions())
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
            let response = NSHTTPURLResponse(URL: URL, MIMEType: "text/html; charset=utf-8",
              expectedContentLength: 100, textEncodingName: nil)

            self.testFailedPromise(promise,
              error: Error.UnacceptableContentType("text/html; charset=utf-8"),
              response: response)
          }
        }

        context("when response is resolved and validation succeeded") {
          it("resolves promise with a result") {
            let response = NSHTTPURLResponse(URL: URL, MIMEType: "application/json; charset=utf-8",
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
            let request = NSMutableURLRequest(URL: URL)
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
