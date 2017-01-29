@testable import Malibu
import Quick
import Nimble

class URLStringConvertibleSpec: QuickSpec {

  override func spec() {
    describe("URLStringConvertible") {
      var value: URLStringConvertible!

      describe("#URLString") {
        context("when it is String") {
          beforeEach {
            value = "http://api.loc"
          }

          it("returns self") {
            expect(value.urlString).to(equal("http://api.loc"))
          }
        }

        context("when it is NSURL") {
          let url = URL(string: "http://api.loc")!

          beforeEach {
            value = url
          }

          it("returns self") {
            expect(value.urlString).to(equal(url.absoluteString))
          }
        }
      }
    }
  }
}
