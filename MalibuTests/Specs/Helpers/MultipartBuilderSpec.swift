@testable import Malibu
import Quick
import Nimble

class MultipartBuilderSpec: QuickSpec {

  override func spec() {
    describe("MultipartBuilder") {
      var builder: MultipartBuilder!
      let parameters = ["firstname": "John", "lastname": "Hyperseed"]

      beforeEach {
        builder = MultipartBuilder()
      }

      describe("buildMultipartString") {
        it("builds multipart string from parameters and boundary value") {
          let components = QueryBuilder().buildComponents(from: parameters)
          var string = ""

          for (key, value) in components {
            string += "--\(boundary)\r\n"
            string += "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
            string += "\(value)\r\n"
          }

          string += "--\(boundary)--\r\n"

          expect(builder.buildMultipartString(from: parameters)).to(equal(string))
        }
      }
    }
  }
}
