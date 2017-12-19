@testable import Malibu
import Quick
import Nimble

final class SessionConfigurationSpec: QuickSpec {
  override func spec() {
    describe("SessionConfiguration") {
      var sessionConfiguration: SessionConfiguration!

      context("when it is a default configuration") {
        beforeEach {
          sessionConfiguration = .default
        }

        describe("#value") {
          it("returns a correct NSURLSessionConfiguration") {
            let value = sessionConfiguration.value
            let expected = URLSessionConfiguration.default
            expected.httpAdditionalHeaders = Header.defaultHeaders

            expect(value).to(equal(expected))
          }

          it("sets additional HTTP headers") {
            let headers = sessionConfiguration.value.httpAdditionalHeaders as? [String: String]
            expect(headers).to(equal(Header.defaultHeaders))
          }
        }
      }

      context("when it is a background configuration") {
        beforeEach {
          sessionConfiguration = .background
        }

        describe("#value") {
          it("returns a correct NSURLSessionConfiguration") {
            let value = sessionConfiguration.value

            expect(value.identifier).to(equal("MalibuBackgroundConfiguration"))
          }

          it("sets additional HTTP headers") {
            let headers = sessionConfiguration.value.httpAdditionalHeaders as? [String: String]
            expect(headers).to(equal(Header.defaultHeaders))
          }
        }
      }

      context("when it is a custom configuration") {
        let configuration = URLSessionConfiguration.default

        beforeEach {
          configuration.requestCachePolicy = .returnCacheDataDontLoad
          sessionConfiguration = .custom(configuration)
        }

        describe("#value") {
          it("returns a correct NSURLSessionConfiguration") {
            let value = sessionConfiguration.value

            expect(value).to(equal(configuration))
            expect(value.requestCachePolicy).to(equal(configuration.requestCachePolicy))
          }

          it("sets additional HTTP headers") {
            let headers = sessionConfiguration.value.httpAdditionalHeaders as? [String: String]
            expect(headers).to(equal(Header.defaultHeaders))
          }
        }
      }
    }
  }
}
