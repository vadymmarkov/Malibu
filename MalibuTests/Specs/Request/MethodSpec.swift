@testable import Malibu
import Quick
import Nimble
import When

class MethodSpec: QuickSpec {

  override func spec() {
    describe("Method") {
      var request: Requestable!

      beforeEach {
        request = TestRequest()
      }

      describe("keyFor") {
        it("bulds a key based on raw value and request URL") {
          expect(Method.GET.keyFor(request)).to(equal("GET http://hyper.no"))
          expect(Method.POST.keyFor(request)).to(equal("POST http://hyper.no"))
          expect(Method.PUT.keyFor(request)).to(equal("PUT http://hyper.no"))
          expect(Method.PATCH.keyFor(request)).to(equal("PATCH http://hyper.no"))
          expect(Method.DELETE.keyFor(request)).to(equal("DELETE http://hyper.no"))
          expect(Method.HEAD.keyFor(request)).to(equal("HEAD http://hyper.no"))
          expect(Method.OPTIONS.keyFor(request)).to(equal("OPTIONS http://hyper.no"))
          expect(Method.TRACE.keyFor(request)).to(equal("TRACE http://hyper.no"))
          expect(Method.CONNECT.keyFor(request)).to(equal("CONNECT http://hyper.no"))
        }
      }
    }
  }
}
