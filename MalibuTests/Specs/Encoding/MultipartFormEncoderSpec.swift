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
          let string = encoder.buildMultipartString(parameters)
          let data = string.dataUsingEncoding(NSUTF8StringEncoding,
                                              allowLossyConversion: true)

          expect{ try encoder.encode(parameters) }.to(equal(data))
        }
      }

      describe("buildMultipartString") {
        it("builds multipart string from parameters and boundary value") {
          let components = QueryBuilder().buildComponents(parameters: parameters)
          var string = ""

          for (key, value) in components {
            string += "--\(boundary)\r\n"
            string += "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
            string += "\(value)\r\n"
          }

          string += "--\(boundary)--\r\n"

          expect(encoder.buildMultipartString(parameters)).to(equal(string))
        }
      }
    }
  }
}
