@testable import Malibu
import Quick
import Nimble
import When

final class ResponseHandlerSpec: QuickSpec {
  override func spec() {
    describe("TaskRunning") {
      var handler: ResponseHandler!
      var data: Data!
      var response: HTTPURLResponse!
      var urlRequest: URLRequest!

      beforeEach {
        urlRequest = try! TestService.showPost(id: 1).request.toUrlRequest()
        let networkPromise = NetworkPromise()
        data = "test".data(using: String.Encoding.utf32)
        response = HTTPURLResponse(
          url: urlRequest.url!, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil
        )
        handler = ResponseHandler(networkPromise: networkPromise)
      }

      describe("#handle") {
        context("when response is nil") {
          it("rejects promise with an error") {
            let expectation = self.expectation(description: "No response failure")

            handler.networkPromise.fail({ error in
              expect(error as! NetworkError == NetworkError.noResponseReceived).to(beTrue())
              expectation.fulfill()
            })

            handler.handle(urlRequest: urlRequest, data: data, urlResponse: nil, error: nil)
            self.waitForExpectations(timeout: 4.0, handler:nil)
          }
        }

        context("when there is an error") {
          it("rejects promise with an error") {
            let expectation = self.expectation(description: "Error failure")
            let promiseError = NetworkError.jsonDictionarySerializationFailed(
              response: Response(data: data, urlRequest: urlRequest, httpUrlResponse: response)
            )

            handler.networkPromise.fail({ error in
              expect( error as! NetworkError == promiseError).to(beTrue())
              expectation.fulfill()
            })

            handler.handle(
              urlRequest: urlRequest,
              data: data,
              urlResponse: response,
              error: promiseError
            )
            self.waitForExpectations(timeout: 4.0, handler:nil)
          }
        }

        context("when there is no data") {
          it("rejects promise with an error") {
            let expectation = self.expectation(description: "No data failure")

            handler.networkPromise.fail({ error in
              expect(error as! NetworkError == NetworkError.noDataInResponse).to(beTrue())
              expectation.fulfill()
            })

            handler.handle(urlRequest: urlRequest, data: nil, urlResponse: response, error: nil)
            self.waitForExpectations(timeout: 4.0, handler:nil)
          }
        }

        context("when validation succeeded") {
          it("resolves promise with a result") {
            let expectation = self.expectation(description: "Validation succeeded")

            handler.networkPromise.done({ result in
              expect(result.data).to(equal(data))
              expect(result.urlRequest).to(equal(urlRequest))
              expect(result.httpUrlResponse).to(equal(response))

              expectation.fulfill()
            })

            handler.handle(urlRequest: urlRequest, data: data, urlResponse: response, error: nil)
            self.waitForExpectations(timeout: 4.0, handler:nil)
          }
        }
      }
    }
  }
}
