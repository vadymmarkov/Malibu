@testable import Malibu
import Quick
import Nimble

class NetworkingSpec: QuickSpec {

  override func spec() {
    describe("Networking") {
      var networking: Networking<TestEndpoint>!

      beforeEach {
        networking = Networking()
        Malibu.mode = .partial
      }

      afterEach {
        Malibu.mode = .regular
      }

      describe("#init") {
        it("sets default configuration to the session") {
          expect(networking.session.configuration).to(equal(SessionConfiguration.default.value))
        }
      }

      describe("#request") {
        context("when request has a mock") {
          it("returns a mock data") {
            let expectation = self.expectation(description: "Request")

            networking.request(.showPost(id: 1)).toJsonDictionary().done({ json in
              expect(json["title"] as? String).to(equal("Test"))
              expectation.fulfill()
            })

            self.waitForExpectations(timeout: 1.0, handler: nil)
          }
        }
      }
    }
  }
}
