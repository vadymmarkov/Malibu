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
            value = "http://hyper.no"
          }

          it("returns self") {
            expect(value.urlString).to(equal("http://hyper.no"))
          }
        }

        context("when it is NSURL") {
          let url = URL(string: "http://hyper.no")!

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
