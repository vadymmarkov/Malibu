@testable import Malibu
import Quick
import Nimble
import When

// MARK: - Mocks

private final class MockAsyncOperation: AsynchronousOperation {
  override func execute() {}
}

class AsynchronousOperationSpec: QuickSpec {
  override func spec() {
    describe("ConcurrentOperation") {
      var operation: AsynchronousOperation!

      beforeEach {
        operation = MockAsyncOperation()
      }

      describe("#init") {
        it("sets a state") {
          expect(operation.state).to(equal(AsynchronousOperation.State.ready))
        }
      }

      describe("#state") {
        context("Ready") {
          it("changes isReady property") {
            operation.state = .ready
            expect(operation.value(forKey: "isReady") as? Bool).to(beTrue())
          }
        }

        context("Executing") {
          it("changes isExecuting property") {
            operation.state = .executing
            expect(operation.value(forKey: "isExecuting") as? Bool).to(beTrue())
          }
        }

        context("Finished") {
          it("changes isFinished property") {
            operation.state = .finished
            expect(operation.value(forKey: "isFinished") as? Bool).to(beTrue())
          }
        }
      }

      describe("#isAsynchronous") {
        it("is set to true") {
          expect(operation.isAsynchronous).to(beTrue())
        }
      }

      describe("#isReady") {
        it("changes to true when state is set to .Ready") {
          operation.state = .ready
          expect(operation.isReady).to(beTrue())
        }
      }

      describe("#isExecuting") {
        it("changes to true when state is set to .Ready") {
          operation.state = .executing
          expect(operation.isExecuting).to(beTrue())
        }
      }

      describe("#isFinished") {
        it("changes to true when state is set to .Finished") {
          operation.state = .finished
          expect(operation.isFinished).to(beTrue())
        }
      }

      describe("#start") {
        context("when it's ready") {
          it("starts operation") {
            operation.start()
            expect(operation.isExecuting).to(beTrue())
          }
        }

        context("when it's cancelled") {
          it("doesn't start operation") {
            operation.cancel()
            operation.start()
            expect(operation.isExecuting).to(beFalse())
            expect(operation.isFinished).to(beTrue())
          }
        }
      }
    }
  }
}
