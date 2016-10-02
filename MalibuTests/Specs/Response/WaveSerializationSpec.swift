@testable import Malibu
import When
import Quick
import Nimble

class WaveSerializationSpec: QuickSpec, NetworkPromiseSpec {

  var networkPromise: Ride!
  var request: URLRequest!
  var data: Data!

  override func spec() {
    describe("WaveSerialization") {

      let URL = Foundation.URL(string: "http://hyper.no")!
      let response = HTTPURLResponse(url: URL, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)!

      // MARK: - Specs

      beforeEach {
        self.networkPromise = Ride()
        self.request = URLRequest(url: Foundation.URL(string: "http://hyper.no")!)
        self.data = try! JSONSerialization.data(withJSONObject: [["name": "Taylor"]],
          options: JSONSerialization.WritingOptions())
      }

      describe("#toString") {
        var promise: Promise<String>!

        beforeEach {
          promise = self.networkPromise.toString(String.Encoding.utf8)
        }

        context("when response is rejected") {
          it("rejects promise with an error") {
            self.testFailedResponse(promise)
          }
        }

        context("when response is resolved") {
          context("when serialization fails") {
            it("rejects promise with an error") {
              self.data = "string".data(using: String.Encoding.utf32)

              self.testFailedPromise(
                promise,
                error: NetworkError.stringSerializationFailed(String.Encoding.utf8.rawValue),
                response: response)
            }
          }

          context("when there is no data in response") {
            it("rejects promise with an error") {
              self.data = Data()

              self.testFailedPromise(promise, error: NetworkError.noDataInResponse,
                response: response)
            }
          }

          context("when response status code is 204 No Content") {
            it("resolves promise with an empty string") {
              self.data = Data()
              let response = HTTPURLResponse(url: URL, statusCode: 204, httpVersion: "HTTP/2.0", headerFields: nil)!

              self.testSucceededPromise(promise, response: response) { result in
                expect(result.isEmpty).to(beTrue())
              }
            }
          }

          context("when serialization succeeded") {
            it("resolves promise with a result") {
              let string = "string"
              self.data = string.data(using: String.Encoding.utf8)

              self.testSucceededPromise(promise, response: response) { result in
                expect(result == string).to(beTrue())
              }
            }
          }
        }
      }

      describe("#toJSONArray") {
        var promise: Promise<[[String: Any]]>!

        beforeEach {
          promise = self.networkPromise.toJSONArray()
        }

        context("when response is rejected") {
          it("rejects promise with an error") {
            self.testFailedResponse(promise)
          }
        }

        context("when response is resolved") {
          context("when serialization fails") {
            it("rejects promise with an error") {
              self.data = try! JSONSerialization.data(withJSONObject: ["name": "Taylor"],
                options: JSONSerialization.WritingOptions())

              self.testFailedPromise(promise, error: NetworkError.jsonArraySerializationFailed,
                response: response)
            }
          }

          context("when there is no data in response") {
            it("rejects promise with an error") {
              self.data = Data()

              self.testFailedPromise(promise, error: NetworkError.noDataInResponse,
                response: response)
            }
          }

          context("when response status code is 204 No Content") {
            it("resolves promise with an empty array") {
              self.data = Data()
              let response = HTTPURLResponse(url: URL, statusCode: 204, httpVersion: "HTTP/2.0", headerFields: nil)!

              self.testSucceededPromise(promise, response: response) { result in
                expect(result).to(equal([]))
              }
            }
          }

          context("when serialization succeeded") {
            it("resolves promise with a result") {
              let array = [["name": "Taylor"]]
              self.data = try! JSONSerialization.data(withJSONObject: array,
                options: JSONSerialization.WritingOptions())

              self.testSucceededPromise(promise, response: response) { result in
                expect(result).to(equal(array))
              }
            }
          }
        }
      }

      describe("#toJSONDictionary") {
        var promise: Promise<[String: Any]>!

        beforeEach {
          promise = self.networkPromise.toJSONDictionary()
        }

        context("when response is rejected") {
          it("rejects promise with an error") {
            self.testFailedResponse(promise)
          }
        }

        context("when response is resolved") {
          context("when serialization fails") {
            it("rejects promise with an error") {
              self.data = try! JSONSerialization.data(withJSONObject: [["name": "Taylor"]],
                options: JSONSerialization.WritingOptions())

              self.testFailedPromise(
                promise,
                error: NetworkError.jsonDictionarySerializationFailed,
                response: response)
            }
          }

          context("when there is no data in response") {
            it("rejects promise with an error") {
              self.data = Data()

              self.testFailedPromise(promise, error: NetworkError.noDataInResponse,
                response: response)
            }
          }

          context("when response status code is 204 No Content") {
            it("resolves promise with an empty dictionary") {
              self.data = Data()
              let response = HTTPURLResponse(url: URL, statusCode: 204, httpVersion: "HTTP/2.0", headerFields: nil)!

              self.testSucceededPromise(promise, response: response) { result in
                if let stringDictionary = result as? [String: String] {
                  expect(stringDictionary).to(equal([:]))
                }
              }
            }
          }

          context("when serialization succeeded") {
            it("resolves promise with a result") {
              let dictionary = ["name": "Taylor"]
              self.data = try! JSONSerialization.data(withJSONObject: dictionary,
                options: JSONSerialization.WritingOptions())

              self.testSucceededPromise(promise, response: response) { result in
                if let stringDictionary = result as? [String: String] {
                  expect(stringDictionary).to(equal(dictionary))
                }
              }
            }
          }
        }
      }
    }
  }
}
