@testable import Malibu
import Quick
import Nimble
import When

class ResponseHandlerSpec: QuickSpec {

  override func spec() {
    describe("TaskRunning") {
      var handler: TestResponseHandler!

      beforeEach {
        handler = TestResponseHandler()
      }

      describe("#handle") {
        context("when response is nil") {
          it("rejects promise with an error") {
            let expectation = self.expectation(description: "No response failure")

            handler.ride.fail({ error in
              expect(error as! NetworkError == NetworkError.noResponseReceived).to(beTrue())
              expectation.fulfill()
            })

            handler.handle(data: handler.data, response: nil, error: nil)

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
              data: handler.data,
              response: handler.response,
              error: NetworkError.jsonDictionarySerializationFailed)

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

            handler.handle(data: nil, response: handler.response, error: nil)

            self.waitForExpectations(timeout: 4.0, handler:nil)
          }
        }

        context("when validation succeeded") {
          it("resolves promise with a result") {
            let expectation = self.expectation(description: "Validation succeeded")

            handler.ride.done({ result in
              expect(result.data).to(equal(handler.data))
              expect(result.request).to(equal(handler.urlRequest))
              expect(result.response).to(equal(handler.response))

              expectation.fulfill()
            })

            handler.handle(data: handler.data, response: handler.response, error: nil)

            self.waitForExpectations(timeout: 4.0, handler:nil)
          }
        }
      }
    }
  }
}
