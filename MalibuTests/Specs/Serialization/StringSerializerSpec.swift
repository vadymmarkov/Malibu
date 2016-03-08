@testable import Malibu
import Quick
import Nimble

class StringSerializerSpec: QuickSpec {

  override func spec() {
    describe("StringSerializer") {
      var serializer: StringSerializer!
      let URL = NSURL(string: "http://hyper.no")!
      let response = NSHTTPURLResponse(URL: URL, statusCode: 200, HTTPVersion: "HTTP/2.0", headerFields: nil)!

      beforeEach {
        serializer = StringSerializer()
      }

      describe("#init") {
        it("sets default encoding") {
          expect(serializer.encoding).to(beNil())
        }

        it("sets parameter encoding to the instance var") {
          serializer = StringSerializer(encoding: NSUTF8StringEncoding)
          expect(serializer.encoding).to(equal(NSUTF8StringEncoding))
        }
      }

      describe("#serialize") {
        context("when there is no data in response") {
          it("throws an error") {
            let data = NSData()
            expect{ try serializer.serialize(data, response: response) }.to(throwError(Error.NoDataInResponse))
          }
        }

        context("when string could not be serialized with specified encoding") {
          it("throws an error") {
            serializer = StringSerializer(encoding: NSUTF8StringEncoding)
            let string = "string"
            let data = string.dataUsingEncoding(NSUTF32StringEncoding)!

            expect{ try serializer.serialize(data, response: response) }.to(
              throwError(Error.StringSerializationFailed(NSUTF8StringEncoding)))
          }
        }

        context("when string could not be serialized with an encoding from the response") {
          it("throws an error") {
            let response = NSHTTPURLResponse(URL: URL, MIMEType: nil, expectedContentLength: 10, textEncodingName: "utf-32")
            let string = "string"
            let data = string.dataUsingEncoding(NSUTF16BigEndianStringEncoding)!

            expect{ try serializer.serialize(data, response: response) }.to(
              throwError(Error.StringSerializationFailed(NSUTF32StringEncoding)))
          }
        }

        context("when response status code is 204 No Content") {
          it("does not throw an error and returns an empty string") {
            let response = NSHTTPURLResponse(URL: URL, statusCode: 204,
              HTTPVersion: "HTTP/2.0", headerFields: nil)!
            let data = NSData()
            var result: String?

            expect{ result = try serializer.serialize(data, response: response) }.toNot(throwError())
            expect(result).to(equal(""))
          }
        }

        context("when serialization succeeded") {
          it("does not throw an error and returns result") {
            let string = "string"
            let data = string.dataUsingEncoding(NSUTF8StringEncoding)!
            var result: String?

            expect{ result = try serializer.serialize(data, response: response) }.toNot(throwError())
            expect(result).to(equal(string))
          }
        }
      }
    }
  }
}
