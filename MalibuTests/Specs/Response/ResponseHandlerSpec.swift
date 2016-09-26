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
            let expectation = self.expectationWithDescription("No response failure")

            handler.ride.fail({ error in
              expect(error as! Error == Error.NoResponseReceived).to(beTrue())
              expectation.fulfill()
            })

            handler.handle(handler.data, response: nil, error: nil)

            self.waitForExpectationsWithTimeout(4.0, handler:nil)
          }
        }

        context("when there is an error") {
          it("rejects promise with an error") {
            let expectation = self.expectationWithDescription("Error failure")

            handler.ride.fail({ error in
              expect(error as! Error == Error.JSONDictionarySerializationFailed).to(beTrue())
              expectation.fulfill()
            })

            handler.handle(handler.data, response: handler.response, error: Error.JSONDictionarySerializationFailed)

            self.waitForExpectationsWithTimeout(4.0, handler:nil)
          }
        }

        context("when there is no data") {
          it("rejects promise with an error") {
            let expectation = self.expectationWithDescription("No data failure")

            handler.ride.fail({ error in
              expect(error as! Error == Error.NoDataInResponse).to(beTrue())
              expectation.fulfill()
            })

            handler.handle(nil, response: handler.response, error: nil)

            self.waitForExpectationsWithTimeout(4.0, handler:nil)
          }
        }

        context("when validation succeeded") {
          it("resolves promise with a result") {
            let expectation = self.expectationWithDescription("Validation succeeded")

            handler.ride.done({ result in
              expect(result.data).to(equal(handler.data))
              expect(result.request).to(equal(handler.URLRequest))
              expect(result.response).to(equal(handler.response))

              expectation.fulfill()
            })

            handler.handle(handler.data, response: handler.response, error: nil)

            self.waitForExpectationsWithTimeout(4.0, handler:nil)
          }
        }
      }
    }
  }
}
