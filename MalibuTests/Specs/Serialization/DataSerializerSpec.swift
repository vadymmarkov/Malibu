@testable import Malibu
import Quick
import Nimble

class DataSerializerSpec: QuickSpec {

  override func spec() {
    describe("DataSerializer") {
      var serializer: DataSerializer!
      let URL = NSURL(string: "http://hyper.no")!
      let response = NSHTTPURLResponse(URL: URL, statusCode: 200, HTTPVersion: "HTTP/2.0", headerFields: nil)!

      beforeEach {
        serializer = DataSerializer()
      }

      describe("#serialize") {
        context("when there is no data in response") {
          it("throws an error") {
            let data = NSData()
            expect{ try serializer.serialize(data, response: response) }.to(throwError(Error.NoDataInResponse))
          }
        }

        context("when response status code is 204 No Content") {
          it("does not throw an error and returns empty data object") {
            let response = NSHTTPURLResponse(URL: URL, statusCode: 204,
              HTTPVersion: "HTTP/2.0", headerFields: nil)!
            let data = NSData()
            var result: NSData?

            expect{ result = try serializer.serialize(data, response: response) }.toNot(throwError())
            expect(result).to(equal(NSData()))
          }
        }

        context("when serialization succeeded") {
          it("does not throw an error and returns result") {
            let dictionary = ["name": "Taylor"]
            let data = try! NSJSONSerialization.dataWithJSONObject(dictionary,
              options: NSJSONWritingOptions())
            var result: NSData?

            expect{ result = try serializer.serialize(data, response: response) }.toNot(throwError())
            expect(result).to(equal(data))
          }
        }
      }
    }
  }
}
