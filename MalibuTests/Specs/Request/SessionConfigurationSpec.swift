@testable import Malibu
import Quick
import Nimble

class SessionConfigurationSpec: QuickSpec {

  override func spec() {
    describe("SessionConfiguration") {
      var sessionConfiguration: SessionConfiguration!

      context("when it is Default configuration") {
        beforeEach {
          sessionConfiguration = .Default
        }

        describe("#value") {
          it("returns a correct NSURLSessionConfiguration") {
            let value = sessionConfiguration.value
            let expected = NSURLSessionConfiguration.defaultSessionConfiguration()
            expected.HTTPAdditionalHeaders = Header.defaultHeaders

            expect(value).to(equal(expected))
          }

          it("sets additional HTTP headers") {
            let headers = sessionConfiguration.value.HTTPAdditionalHeaders as? [String: String]
            expect(headers).to(equal(Header.defaultHeaders))
          }
        }
      }

      context("when it is Background configuration") {
        beforeEach {
          sessionConfiguration = .Background
        }

        describe("#value") {
          it("returns a correct NSURLSessionConfiguration") {
            let value = sessionConfiguration.value

            expect(value.identifier).to(equal("MalibuBackgroundConfiguration"))
          }

          it("sets additional HTTP headers") {
            let headers = sessionConfiguration.value.HTTPAdditionalHeaders as? [String: String]
            expect(headers).to(equal(Header.defaultHeaders))
          }
        }
      }

      context("when it is Custom configuration") {
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

          it("sets additional HTTP headers") {
            let headers = sessionConfiguration.value.HTTPAdditionalHeaders as? [String: String]
            expect(headers).to(equal(Header.defaultHeaders))
          }
        }
      }
    }
  }
}
