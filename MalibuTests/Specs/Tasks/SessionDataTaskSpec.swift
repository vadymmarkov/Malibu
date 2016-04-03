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
      let promise = Promise<NetworkResult>()

      describe("#init") {
        beforeEach {
          task = SessionDataTask(session: session, URLRequest: URLRequest, promise: promise)
        }

        it("sets properties") {
          expect(task.session).to(equal(session))
          expect(task.URLRequest).to(equal(URLRequest))
          expect(task.promise === promise).to(beTrue())
        }
      }
    }
  }
}
