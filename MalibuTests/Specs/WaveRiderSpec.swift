@testable import Malibu
import Quick
import Nimble

class WaveRiderSpec: QuickSpec {
  
  override func spec() {
    describe("WaveRider") {      
      describe(".parameterEncoders") {
        it("has default encoders for content types") {
          expect(WaveRider.parameterEncoders.isEmpty).to(beFalse())
          expect(WaveRider.parameterEncoders[.JSON] is JSONParameterEncoder).to(beTrue())
          expect(WaveRider.parameterEncoders[.FormURLEncoded] is FormURLEncoder).to(beTrue())
        }
      }
    }
  }
}
