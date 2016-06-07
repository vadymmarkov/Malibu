@testable import Malibu
import Quick
import Nimble
import When

class SessionDataTaskSpec: QuickSpec {

  override func spec() {
    describe("SessionDataTask") {
      var task: SessionDataTask!
      let session = NSURLSession()
      let URLRequest = try! GETRequest().toURLRequest()
      let ride = Ride()

      describe("#init") {
        beforeEach {
          task = SessionDataTask(session: session, URLRequest: URLRequest, ride: ride)
        }

        it("sets properties") {
          expect(task.session).to(equal(session))
          expect(task.URLRequest).to(equal(URLRequest))
          expect(task.ride === ride).to(beTrue())
        }
      }
    }
  }
}
