@testable import Malibu
import When
import Quick
import Nimble

final class ResponseDecodingSpec: QuickSpec, NetworkPromiseSpec {
  var networkPromise: NetworkPromise!
  var request: URLRequest!
  var data: Data!

  override func spec() {
    describe("ResponseDecoding") {
      let url = URL(string: "http://api.loc")!
      let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)!
      let decoder = JSONDecoder()

      // MARK: - Specs

      beforeEach {
        self.networkPromise = NetworkPromise()
        self.request = URLRequest(url: URL(string: "http://api.loc")!)
        self.data = try! JSONSerialization.data(
          withJSONObject: [["name": "Taylor"]],
          options: JSONSerialization.WritingOptions()
        )
      }

      describe("#decode") {
        var promise: Promise<[Int]>!

        beforeEach {
          promise = self.networkPromise.decode(using: [Int].self, decoder: decoder)
        }

        context("when response is rejected") {
          it("rejects promise with an error") {
            self.testFailedResponse(promise)
          }
        }

        context("when response is resolved") {
          context("when decoding fails") {
            it("rejects promise with an error") {
              self.data = "string".data(using: String.Encoding.utf32)
              let response = self.makeResponse(statusCode: 200, data: self.data)

              self.testFailedPromise(
                promise,
                error: NetworkError.responseDecodingFailed(type: [Int].self, response: response),
                response: response.httpUrlResponse)
            }
          }

          context("when there is no data in response") {
            it("rejects promise with an error") {
              self.data = Data()

              self.testFailedPromise(
                promise,
                error: NetworkError.noDataInResponse,
                response: response
              )
            }
          }

          context("when decoding succeeded") {
            it("resolves promise with the specified type") {
              let string = "[1,2,3]"
              self.data = string.data(using: String.Encoding.utf8)

              self.testSucceededPromise(promise, response: response) { result in
                expect(result == [1, 2, 3]).to(beTrue())
              }
            }
          }
        }
      }
    }
  }
}
