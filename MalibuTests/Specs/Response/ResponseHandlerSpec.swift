@testable import Malibu
import Quick
import Nimble
import When

class ResponseHandlerSpec: QuickSpec {

  override func spec() {
    describe("TaskRunning") {
      var handler: ResponseHandler!
      var data: Data!
      var response: HTTPURLResponse!

      beforeEach {
        let urlRequest = try! TestService.showPost(id: 1).request.toUrlRequest()
        let ride = Ride()
        data = "test".data(using: String.Encoding.utf32)
        response = HTTPURLResponse(
          url: urlRequest.url!, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil
        )
        handler = ResponseHandler(urlRequest: urlRequest, ride: ride)
      }

      describe("#handle") {
        context("when response is nil") {
          it("rejects promise with an error") {
            let expectation = self.expectation(description: "No response failure")

            handler.ride.fail({ error in
              expect(error as! NetworkError == NetworkError.noResponseReceived).to(beTrue())
              expectation.fulfill()
            })

            handler.handle(data: data, urlResponse: nil, error: nil)
            self.waitForExpectations(timeout: 4.0, handler:nil)
          }
        }

        context("when there is an error") {
          it("rejects promise with an error") {
            let expectation = self.expectation(description: "Error failure")

            handler.ride.fail({ error in
              expect(error as! NetworkError == NetworkError.jsonDictionarySerializationFailed).to(beTrue())
              expectation.fulfill()
            })

            handler.handle(
              data: data,
              urlResponse: response,
              error: NetworkError.jsonDictionarySerializationFailed
            )
            self.waitForExpectations(timeout: 4.0, handler:nil)
          }
        }

        context("when there is no data") {
          it("rejects promise with an error") {
            let expectation = self.expectation(description: "No data failure")

            handler.ride.fail({ error in
              expect(error as! NetworkError == NetworkError.noDataInResponse).to(beTrue())
              expectation.fulfill()
            })

            handler.handle(data: nil, urlResponse: response, error: nil)
            self.waitForExpectations(timeout: 4.0, handler:nil)
          }
        }

        context("when validation succeeded") {
          it("resolves promise with a result") {
            let expectation = self.expectation(description: "Validation succeeded")

            handler.ride.done({ result in
              expect(result.data).to(equal(data))
              expect(result.request).to(equal(handler.urlRequest))
              expect(result.response).to(equal(response))

              expectation.fulfill()
            })

            handler.handle(data: data, urlResponse: response, error: nil)
            self.waitForExpectations(timeout: 4.0, handler:nil)
          }
        }
      }
    }
  }
}
