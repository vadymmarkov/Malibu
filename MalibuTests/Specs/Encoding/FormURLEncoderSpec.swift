@testable import Malibu
import Quick
import Nimble

class FormURLEncoderSpec: QuickSpec {

  override func spec() {
    describe("FormURLEncoder") {
      var encoder: FormURLEncoder!

      beforeEach {
        encoder = FormURLEncoder()
      }

      describe("#encode") {
        it("encodes a dictionary of parameters to NSData object") {
          let parameters = ["firstname": "John", "lastname": "Hyperseed"]
          let string = QueryBuilder().buildQuery(parameters)
          let data = string.dataUsingEncoding(String.Encoding.utf8,
            allowLossyConversion: false)

          expect{ try encoder.encode(parameters) }.to(equal(data))
        }
      }
    }
  }
}
