@testable import Malibu
import Quick
import Nimble

class NetworkingSpec: QuickSpec {

  override func spec() {
    describe("Networking") {
      var networking: Networking!

      beforeEach {
        networking = Networking()
      }

      describe("#init") {
        it("sets default configuration to the session") {
          networking = Networking()

          expect(networking.session.configuration).to(equal(SessionConfiguration.Default.value))
        }

        it("sets custom configuration to the session") {
          networking = Networking(sessionConfiguration: .Background)

          expect(networking.session.configuration.identifier).to(equal("MalibuBackgroundConfiguration"))
        }
      }

      describe("#register:mock") {
        it("registers mock for the provided method") {
          let request = GETRequest()
          let mock = Mock(request: request, response: nil, data: nil, error: nil)

          networking.register(mock: mock)

          expect(networking.mocks["GET http://hyper.no"] === mock).to(beTrue())
        }
      }

      describe("#prepareMock") {
        it("runs beforeEach closure on mocked request and returns registered mock") {
          let request = GETRequest()
          let mock = Mock(request: request, response: nil, data: nil, error: nil)

          networking.register(mock: mock)
          networking.beforeEach = { (request: Requestable) in
            var request = request
            request.message.parameters["test"] = true

            return request
          }

          let result = networking.prepareMock(request)

          expect(result).toNot(beNil())
          expect(result?.request.message.parameters["test"] as? Bool).to(beTrue())
        }
      }
    }
  }
}
