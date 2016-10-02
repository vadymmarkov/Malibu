@testable import Malibu
import Quick
import Nimble

class JSONSerializerSpec: QuickSpec {

  override func spec() {
    describe("JSONSerializer") {
      var serializer: JSONSerializer!
      let url = URL(string: "http://hyper.no")!
      let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)!

      beforeEach {
        serializer = JSONSerializer()
      }

      describe("#init") {
        it("sets default options") {
          expect(serializer.options).to(equal(JSONSerialization.ReadingOptions.AllowFragments))
        }

        it("sets parameter options to the instance var") {
          serializer = JSONSerializer(options: .MutableContainers)
          expect(serializer.options).to(equal(JSONSerialization.ReadingOptions.MutableContainers))
        }
      }

      describe("#serialize") {
        context("when there is no data in response") {
          it("throws an error") {
            let data = Data()
            expect{ try serializer.serialize(data, response: response) }.to(throwError(Error.NoDataInResponse))
          }
        }

        context("when the data will not produce valid JSON") {
          it("throws an error") {
            let data = "ff^%^$".data(using: String.Encoding.utf8)!
            expect{ try serializer.serialize(data, response: response) }.to(throwError())
          }
        }

        context("when response status code is 204 No Content") {
          it("does not throw an error and returns NSNull") {
            let response = HTTPURLResponse(url: url, statusCode: 204,
              httpVersion: "HTTP/2.0", headerFields: nil)!
            let data = Data()
            var result: AnyObject?

            expect{ result = try serializer.serialize(data, response: response) }.toNot(throwError())
            expect(result is NSNull).to(beTrue())
          }
        }

        context("when serialization succeeded") {
          it("does not throw an error and returns result") {
            let dictionary = ["name": "Taylor"]
            let data = try! JSONSerialization.data(withJSONObject: dictionary,
              options: JSONSerialization.WritingOptions())
            var result: AnyObject?

            expect{ result = try serializer.serialize(data, response: response) }.toNot(throwError())
            expect(result as? [String: String]).to(equal(dictionary))
          }
        }
      }
    }
  }
}
