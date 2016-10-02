@testable import Malibu
import Quick
import Nimble
import When

class ConcurrentOperationSpec: QuickSpec {

  override func spec() {
    describe("ConcurrentOperation") {
      var operation: ConcurrentOperation!

      beforeEach {
        operation = ConcurrentOperation()
      }

      describe("#init") {
        it("sets a state") {
          expect(operation.state).to(equal(ConcurrentOperation.State.Ready))
        }
      }

      describe("#state") {
        context("Ready") {
          it("changes isReady property") {
            operation.state = .Ready
            expect(operation.value(forKey: "isReady") as? Bool).to(beTrue())
          }
        }

        context("Executing") {
          it("changes isExecuting property") {
            operation.state = .Executing
            expect(operation.value(forKey: "isExecuting") as? Bool).to(beTrue())
          }
        }

        context("Finished") {
          it("changes isFinished property") {
            operation.state = .Finished
            expect(operation.value(forKey: "isFinished") as? Bool).to(beTrue())
          }
        }
      }

      describe("#asynchronous") {
        it("is set to true") {
          expect(operation.isAsynchronous).to(beTrue())
        }
      }

      describe("#ready") {
        it("changes to true when state is set to .Ready") {
          operation.state = .Ready
          expect(operation.isReady).to(beTrue())
        }
      }

      describe("#executing") {
        it("changes to true when state is set to .Ready") {
          operation.state = .Executing
          expect(operation.isExecuting).to(beTrue())
        }
      }

      describe("#finished") {
        it("changes to true when state is set to .Finished") {
          operation.state = .Finished
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

      describe("#execute") {
        it("changes a state") {
          operation.execute()
          expect(operation.isExecuting).to(beTrue())
        }
      }
    }
  }
}
