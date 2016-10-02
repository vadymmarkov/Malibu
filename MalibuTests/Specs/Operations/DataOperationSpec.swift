@testable import Malibu
import Quick
import Nimble
import When

class DataOperationSpec: QuickSpec {

  override func spec() {
    describe("DataOperation") {
      var operation: DataOperation!
      let session = URLSession()
      let urlRequest = try! GETRequest().toURLRequest()
      let ride = Ride()

      describe("#init") {
        beforeEach {
          operation = DataOperation(session: session, urlRequest: urlRequest, ride: ride)
        }

        it("sets properties") {
          expect(operation.session).to(equal(session))
          expect(operation.URLRequest).to(equal(URLRequest))
          expect(operation.ride === ride).to(beTrue())
        }
      }
    }
  }
}
