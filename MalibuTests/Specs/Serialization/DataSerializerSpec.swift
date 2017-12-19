@testable import Malibu
import Quick
import Nimble

class DataSerializerSpec: QuickSpec {
  override func spec() {
    describe("DataSerializer") {
      var serializer: DataSerializer!
      let url = URL(string: "http://api.loc")!
      let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)!

      beforeEach {
        serializer = DataSerializer()
      }

      describe("#serialize:data") {
        context("when there is no data in response") {
          it("throws an error") {
            let data = Data()
            expect {
              try serializer.serialize(response: Response(
                data: data,
                urlRequest: URLRequest(url: url),
                httpUrlResponse: response)
              )
            }.to(throwError(NetworkError.noDataInResponse))
          }
        }

        context("when response status code is 204 No Content") {
          it("does not throw an error and returns empty data object") {
            let response = HTTPURLResponse(url: url, statusCode: 204,
              httpVersion: "HTTP/2.0", headerFields: nil)!
            let data = Data()
            var result: Data?

            expect {
              result = try serializer.serialize(response: Response(
                data: data,
                urlRequest: URLRequest(url: url),
                httpUrlResponse: response)
              )
            }.toNot(throwError())
            expect(result).to(equal(Data()))
          }
        }

        context("when serialization succeeded") {
          it("does not throw an error and returns result") {
            let dictionary = ["name": "Taylor"]
            let data = try! JSONSerialization.data(withJSONObject: dictionary,
              options: JSONSerialization.WritingOptions())
            var result: Data?

            expect {
              result = try serializer.serialize(response: Response(
                data: data,
                urlRequest: URLRequest(url: url),
                httpUrlResponse: response)
              )
            }.toNot(throwError())
            expect(result).to(equal(data))
          }
        }
      }
    }
  }
}
