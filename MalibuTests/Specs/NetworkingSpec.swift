@testable import Malibu
import Quick
import Nimble

// MARK: - Specs

class NetworkingSpec: QuickSpec {

  override func spec() {
    describe("Networking") {
      describe("#init") {
        it("sets default configuration to the session") {
          let networking = Networking<TestService>()
          expect(networking.session.configuration).to(equal(SessionConfiguration.default.value))
        }
      }

      describe("#request") {
        context("when request has a mock") {
          it("returns a mock data") {
            let mockProvider = MockProvider<TestService> { _ in
              return Mock(json: ["title": "Test"])
            }

            let networking = Networking(mockProvider: mockProvider)
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
