@testable import Malibu
import Quick
import Nimble

class NetworkErrorSpec: QuickSpec {

  override func spec() {
    describe("NetworkError") {
      var error: NetworkError!

      context("when it's noDataInResponse") {
        beforeEach {
          error = .noDataInResponse
        }

        describe("#reason") {
          it("returns a correct string value") {
            expect(error.reason).to(equal("No data in response"))
          }
        }
      }

      context("when it's noDataInResponse") {
        beforeEach {
          error = .noResponseReceived
        }

        describe("#reason") {
          it("returns a correct string value") {
            expect(error.reason).to(equal("No response received"))
          }
        }
      }

      context("when it's unacceptableStatusCode") {
        let statusCode = 401

        beforeEach {
          error = .unacceptableStatusCode(statusCode)
        }

        describe("#reason") {
          it("returns a correct string value") {
            expect(error.reason).to(equal("Response status code \(statusCode) was unacceptable"))
          }
        }
      }

      context("when it's unacceptableStatusCode") {
        let contentType = "application/weirdo"

        beforeEach {
          error = .unacceptableContentType(contentType)
        }

        describe("#reason") {
          it("returns a correct string value") {
            expect(error.reason).to(equal("Response content type \(contentType) was unacceptable"))
          }
        }
      }

      context("when it's noDataInResponse") {
        beforeEach {
          error = .missingContentType
        }

        describe("#reason") {
          it("returns a correct string value") {
            expect(error.reason).to(equal("Response content type was missing"))
          }
        }
      }

      context("when it's offline error") {
        var offlineError: NSError!

        beforeEach {
          offlineError = NSError(
            domain: "no.hyper.Malibu",
            code: Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue),
            userInfo: nil
          )
        }

        describe("#reason") {
          it("returns true") {
            expect(offlineError.isOffline).to(beTrue())
          }
        }
      }
    }
  }
}
