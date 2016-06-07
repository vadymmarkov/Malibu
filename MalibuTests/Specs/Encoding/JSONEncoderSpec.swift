@testable import Malibu
import Quick
import Nimble

class JSONParameterEncoderSpec: QuickSpec {

  override func spec() {
    describe("JSONParameterEncoder") {
      var encoder: JSONEncoder!

      beforeEach {
        encoder = JSONEncoder()
      }

      describe("#encode") {
        it("encodes a dictionary of parameters to NSData object") {
          let parameters = ["firstname": "John", "lastname": "Hyperseed"]
          let data = try! NSJSONSerialization.dataWithJSONObject(parameters,
            options: NSJSONWritingOptions())

          expect{ try encoder.encode(parameters) }.to(equal(data))
        }
      }
    }
  }
}
