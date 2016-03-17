@testable import Malibu
import Quick
import Nimble
import When

class NetworkTaskRunningSpec: QuickSpec {

  override func spec() {
    describe("NetworkTaskRunning") {
      var task: TestNetworkTask!

      beforeEach {
        task = TestNetworkTask()
      }

      describe("process") {
        context("when response is nil") {
          it("rejects promise with an error") {
            let expectation = self.expectationWithDescription("No response failure")

            task.promise.fail({ error in
              expect(error as! Error == Error.NoResponseReceived).to(beTrue())
              expectation.fulfill()
            })

            task.process(task.data, response: nil, error: nil)

            self.waitForExpectationsWithTimeout(4.0, handler:nil)
          }
        }

        context("when there is an error") {
          it("rejects promise with an error") {
            let expectation = self.expectationWithDescription("Error failure")

            task.promise.fail({ error in
              expect(error as! Error == Error.JSONDictionarySerializationFailed).to(beTrue())
              expectation.fulfill()
            })

            task.process(task.data, response: task.response, error: Error.JSONDictionarySerializationFailed)

            self.waitForExpectationsWithTimeout(4.0, handler:nil)
          }
        }

        context("when there is no data") {
          it("rejects promise with an error") {
            let expectation = self.expectationWithDescription("No data failure")

            task.promise.fail({ error in
              expect(error as! Error == Error.NoDataInResponse).to(beTrue())
              expectation.fulfill()
            })

            task.process(nil, response: task.response, error: nil)

            self.waitForExpectationsWithTimeout(4.0, handler:nil)
          }
        }

        context("when validation succeeded") {
          it("rresolves promise with a result") {
            let expectation = self.expectationWithDescription("Validation succeeded")

            task.promise.done({ result in
              expect(result.data).to(equal(task.data))
              expect(result.request).to(equal(task.URLRequest))
              expect(result.response).to(equal(task.response))

              expectation.fulfill()
            })

            task.process(task.data, response: task.response, error: nil)

            self.waitForExpectationsWithTimeout(4.0, handler:nil)
          }
        }
      }
    }
  }
}
