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

      describe("#encode") {
        it("encodes a dictionary of parameters to NSData object") {
          let string = MultipartBuilder().buildMultipartString(parameters)
          let data = string.dataUsingEncoding(NSUTF8StringEncoding,
                                              allowLossyConversion: true)

          expect{ try encoder.encode(parameters) }.to(equal(data))
        }
      }
    }
  }
}
