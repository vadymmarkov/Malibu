@testable import Malibu
import Quick
import Nimble

class NetworkingSpec: QuickSpec {

  override func spec() {
    describe("Networking") {
      var networking: Networking<TestEndpoint>!

      beforeEach {
        networking = Networking()
      }

      describe("#init") {
        it("sets default configuration to the session") {
          networking = Networking()

          expect(networking.session.configuration).to(equal(SessionConfiguration.default.value))
        }
      }
    }
  }
}
