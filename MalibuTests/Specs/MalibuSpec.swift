@testable import Malibu
import Quick
import Nimble

class MalibuSpec: QuickSpec {

  override func spec() {
    describe("Malibu") {
      describe(".parameterEncoders") {
        it("has default encoders for content types") {
          expect(Malibu.parameterEncoders.isEmpty).to(beFalse())
          expect(Malibu.parameterEncoders[.JSON] is JSONParameterEncoder).to(beTrue())
          expect(Malibu.parameterEncoders[.FormURLEncoded] is FormURLEncoder).to(beTrue())
        }
      }
    }
  }
}
