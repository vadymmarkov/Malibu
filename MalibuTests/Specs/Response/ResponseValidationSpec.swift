@testable import Malibu
import When
import Quick
import Nimble

final class ResponseValidationSpec: QuickSpec, NetworkPromiseSpec {
  var networkPromise: NetworkPromise!
  var request: URLRequest!
  var data: Data!

  override func spec() {
    describe("ResponseValidation") {
      let url = URL(string: "http://api.loc")!

      // MARK: - Specs

      beforeEach {
        self.request = URLRequest(url: URL(string: "http://api.loc")!)
        self.data = try! JSONSerialization.data(
          withJSONObject: [["name": "Taylor"]],
          options: JSONSerialization.WritingOptions()
        )
        self.networkPromise = NetworkPromise()
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
            let response = self.makeResponse(statusCode: 404, data: self.data)

            self.testFailedPromise(
              promise,
              error: NetworkError.unacceptableStatusCode(statusCode: 404, response: response),
              response: response.httpUrlResponse
            )
          }
        }

        context("when response is resolved and validation succeeded") {
          it("resolves promise with a result") {
            let response = self.makeResponse(statusCode: 200, data: self.data)
            self.testSucceededPromise(promise, response: response.httpUrlResponse)
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
            let response = self.makeResponse(statusCode: 404, data: self.data)
            self.testFailedPromise(
              promise,
              error: NetworkError.unacceptableStatusCode(statusCode: 404, response: response),
              response: response.httpUrlResponse
            )
          }
        }

        context("when response is resolved and validation succeeded") {
          it("resolves promise with a result") {
            let response = self.makeResponse(statusCode: 200, data: self.data)
            self.testSucceededPromise(promise, response: response.httpUrlResponse)
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
            let httpUrlResponse = HTTPURLResponse(
              url: url,
              mimeType: "text/html; charset=utf-8",
              expectedContentLength: 100,
              textEncodingName: nil
            )
            let response = Response(
              data: self.data,
              urlRequest: self.request,
              httpUrlResponse: httpUrlResponse
            )

            self.testFailedPromise(promise,
              error: NetworkError.unacceptableContentType(
                contentType: "text/html; charset=utf-8",
                response: response
              ),
              response: httpUrlResponse
            )
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
              let response = self.makeResponse(statusCode: 404, data: self.data)
              self.testFailedPromise(
                promise,
                error: NetworkError.unacceptableStatusCode(
                  statusCode: 404,
                  response: response
                ),
                response: response.httpUrlResponse
              )
            }
          }

          context("when response is resolved and validation succeeded") {
            it("resolves response with a result") {
              let response = self.makeResponse(statusCode: 200, data: self.data)
              self.testSucceededPromise(promise, response: response.httpUrlResponse)
            }
          }
        }

        context("with accept header in the request") {
          var promise: Promise<Response>!

          beforeEach {
            self.request = URLRequest(url: url)
            self.request.addValue("text/html; charset=utf-8", forHTTPHeaderField: "Accept")
            promise = self.networkPromise.validate()
          }

          context("when response is rejected") {
            it("rejects promise with an error") {
              self.testFailedResponse(promise)
            }
          }

          context("when response is resolved and validation succeeded") {
            it("resolves promise with a result") {
              let httpUrlResponse = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: "HTTP/2.0",
                headerFields: nil
              )!
              httpUrlResponse.setValue("text/html; charset=utf-8", forKey: "MIMEType")

              let response = Response(
                data: self.data,
                urlRequest: self.request,
                httpUrlResponse: httpUrlResponse
              )

              self.testSucceededPromise(promise, response: response.httpUrlResponse)
            }
          }
        }
      }
    }
  }
}
