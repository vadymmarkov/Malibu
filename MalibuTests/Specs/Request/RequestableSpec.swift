@testable import Malibu
import Quick
import Nimble

class RequestableSpec: QuickSpec {

  override func spec() {
    describe("Requestable") {
      var request: Requestable!

      beforeEach {
        request = TestRequest()
      }

//      describe("#toURLRequest") {
//        context("when request URL is invalid") {
//          it("throws an error") {
//            request.message.resource = "not an URL"
//            expect{ try request.toURLRequest(.GET) }.to(throwError(Error.InvalidRequestURL))
//          }
//        }
//
//        context("when parameters encoding fails") {
//          it("throws an error") {
//            let fakeString = String(bytes: [0xD8, 0x00] as [UInt8],
//              encoding: NSUTF16BigEndianStringEncoding)!
//            request.message.parameters = ["firstname": fakeString]
//
//            expect{ try request.toURLRequest(.GET) }.to(throwError())
//          }
//        }
//
//        context("when there are no errors") {
//          it("does not throw an error and returns created NSMutableURLRequest") {
//            expect{ try request.toURLRequest(.GET) }.toNot(throwError())
//          }
//        }
//      }
    }
  }
}
