@testable import Malibu
import Quick
import Nimble

class JSONSerializerSpec: QuickSpec {

  override func spec() {
    describe("JSONSerializer") {
      var serializer: JSONSerializer!
      let URL = NSURL(string: "http://hyper.no")!
      let response = NSHTTPURLResponse(URL: URL, statusCode: 200, HTTPVersion: "HTTP/2.0", headerFields: nil)!

      beforeEach {
        serializer = JSONSerializer()
      }

      describe("#init") {
        it("sets default options") {
          expect(serializer.options).to(equal(NSJSONReadingOptions.AllowFragments))
        }

        it("sets parameter options to the instance var") {
          serializer = JSONSerializer(options: .MutableContainers)
          expect(serializer.options).to(equal(NSJSONReadingOptions.MutableContainers))
        }
      }

      describe("#serialize") {
        context("when there is no data in response") {
          it("throws an error") {
            let data = NSData()
            expect{ try serializer.serialize(data, response: response) }.to(throwError(Error.NoDataInResponse))
          }
        }

        context("when the data will not produce valid JSON") {
          it("throws an error") {
            let data = "ff^%^$".dataUsingEncoding(NSUTF8StringEncoding)!
            expect{ try serializer.serialize(data, response: response) }.to(throwError())
          }
        }

        context("when response status code is 204 No Content") {
          it("does not throw an error and returns NSNull") {
            let response = NSHTTPURLResponse(URL: URL, statusCode: 204,
              HTTPVersion: "HTTP/2.0", headerFields: nil)!
            let data = NSData()
            var result: AnyObject?

            expect{ result = try serializer.serialize(data, response: response) }.toNot(throwError())
            expect(result is NSNull).to(beTrue())
          }
        }

        context("when serialization succeeded") {
          it("does not throw an error and returns result") {
            let dictionary = ["name": "Taylor"]
            let data = try! NSJSONSerialization.dataWithJSONObject(dictionary,
              options: NSJSONWritingOptions())
            var result: AnyObject?

            expect{ result = try serializer.serialize(data, response: response) }.toNot(throwError())
            expect(result as? [String: String]).to(equal(dictionary))
          }
        }
      }
    }
  }
}
