@testable import Malibu
import Quick
import Nimble

class SessionConfigurationSpec: QuickSpec {

  override func spec() {
    describe("SessionConfiguration") {
      var sessionConfiguration: SessionConfiguration!

      context("when it's Default configuration") {
        beforeEach {
          sessionConfiguration = .Default
        }

        describe("#value") {
          it("returns a correct NSURLSessionConfiguration") {
            let value = sessionConfiguration.value

            expect(value).to(equal(NSURLSessionConfiguration.defaultSessionConfiguration()))
          }
        }
      }

      context("when it's Background configuration") {
        beforeEach {
          sessionConfiguration = .Background
        }

        describe("#value") {
          it("returns a correct NSURLSessionConfiguration") {
            let value = sessionConfiguration.value

            expect(value.identifier).to(equal("MalibuBackgroundConfiguration"))
          }
        }
      }

      context("when it's Custom configuration") {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()

        beforeEach {
          configuration.requestCachePolicy = .ReturnCacheDataDontLoad
          sessionConfiguration = .Custom(configuration)
        }

        describe("#value") {
          it("returns a correct NSURLSessionConfiguration") {
            let value = sessionConfiguration.value

            expect(value).to(equal(configuration))
            expect(value.requestCachePolicy).to(equal(configuration.requestCachePolicy))
          }
        }
      }
    }
  }
}
