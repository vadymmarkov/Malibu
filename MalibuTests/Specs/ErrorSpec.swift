@testable import Malibu
import Quick
import Nimble

class ErrorSpec: QuickSpec {

  override func spec() {
    describe("Error") {
      var error: Error!

      context("when it's NoDataInResponse") {
        beforeEach {
          error = .NoDataInResponse
        }

        describe("#reason") {
          it("returns a correct string value") {
            expect(error.reason).to(equal("No data in response"))
          }
        }
      }

      context("when it's NoDataInResponse") {
        beforeEach {
          error = .NoResponseReceived
        }

        describe("#reason") {
          it("returns a correct string value") {
            expect(error.reason).to(equal("No response received"))
          }
        }
      }

      context("when it's UnacceptableStatusCode") {
        let statusCode = 401

        beforeEach {
          error = .UnacceptableStatusCode(statusCode)
        }

        describe("#reason") {
          it("returns a correct string value") {
            expect(error.reason).to(equal("Response status code \(statusCode) was unacceptable"))
          }
        }
      }

      context("when it's UnacceptableStatusCode") {
        let contentType = "application/weirdo"

        beforeEach {
          error = .UnacceptableContentType(contentType)
        }

        describe("#reason") {
          it("returns a correct string value") {
            expect(error.reason).to(equal("Response content type \(contentType) was unacceptable"))
          }
        }
      }

      context("when it's NoDataInResponse") {
        beforeEach {
          error = .MissingContentType
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
            code: Int(CFNetworkErrors.CFURLErrorNotConnectedToInternet.rawValue),
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
