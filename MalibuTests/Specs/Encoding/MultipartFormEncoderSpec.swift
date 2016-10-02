@testable import Malibu
import Quick
import Nimble

class MultipartFormEncoderSpec: QuickSpec {

  override func spec() {
    describe("MultipartFormEncoder") {
      var encoder: MultipartFormEncoder!
      let parameters = ["firstname": "John", "lastname": "Hyperseed"]

      beforeEach {
        encoder = MultipartFormEncoder()
      }

      describe("#encode:parameters") {
        it("encodes a dictionary of parameters to NSData object") {
          let string = MultipartBuilder().buildMultipartString(from: parameters)
          let data = string.data(using: String.Encoding.utf8,
                                 allowLossyConversion: true)

          expect{ try encoder.encode(parameters: parameters) }.to(equal(data))
        }
      }
    }
  }
}
