@testable import Malibu
import Quick
import Nimble

class ParameterizedRequestableSpec: QuickSpec {

  override func spec() {
    describe("ParameterizedRequestable") {
      var request: ParameterizedRequestable!

      beforeEach {
        request = TestRequest(parameters: ["key": "value"], headers: ["key": "value"])
        ETagStorage().clear()
      }

      afterSuite {
        do {
          try NSFileManager.defaultManager().removeItemAtPath(Utils.storageDirectory)
        } catch {}
      }

      describe("#init") {
        it("sets parameters to the message") {
          expect(request.message.parameters.count).to(equal(1))
          expect(request.message.parameters["key"] as? String).to(equal("value"))
        }

        it("sets headers to the message") {
          expect(request.message.headers.count).to(equal(1))
          expect(request.message.headers["key"]).to(equal("value"))
        }
      }
    }
  }
}
