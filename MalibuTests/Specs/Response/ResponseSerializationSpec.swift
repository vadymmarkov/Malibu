@testable import Malibu
import When
import Quick
import Nimble

class ResponseSerializationSpec: QuickSpec, NetworkPromiseSpec {

  var networkPromise: NetworkPromise!
  var request: URLRequest!
  var data: Data!

  override func spec() {
    describe("ResponseSerialization") {
      let url = URL(string: "http://api.loc")!
      let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)!

      // MARK: - Specs

      beforeEach {
        self.networkPromise = NetworkPromise()
        self.request = URLRequest(url: URL(string: "http://api.loc")!)
        self.data = try! JSONSerialization.data(
          withJSONObject: [["name": "Taylor"]],
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
              let response = HTTPURLResponse(url: url, statusCode: 204,
                                             httpVersion: "HTTP/2.0",
                                             headerFields: nil)!

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

      describe("#toJsonArray") {
        var promise: Promise<[[String: Any]]>!

        beforeEach {
          promise = self.networkPromise.toJsonArray()
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
              let response = HTTPURLResponse(url: url, statusCode: 204,
                                             httpVersion: "HTTP/2.0", headerFields: nil)!

              self.testSucceededPromise(promise, response: response) { (result: [[String: Any]]) in
                expect(result.isEmpty).to(beTrue())
              }
            }
          }

          context("when serialization succeeded") {
            it("resolves promise with a result") {
              let array: [[String: Any]] = [["name": "Taylor"]]
              self.data = try! JSONSerialization.data(withJSONObject: array,
                options: JSONSerialization.WritingOptions())

              self.testSucceededPromise(promise, response: response) { (result: [[String: Any]]) in
                expect(result.count).to(equal(1))
                expect(result[0].count).to(equal(1))
                expect(result[0]["name"] as? String).to(equal("Taylor"))
              }
            }
          }
        }
      }

      describe("#toJsonDictionary") {
        var promise: Promise<[String: Any]>!

        beforeEach {
          promise = self.networkPromise.toJsonDictionary()
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
              let response = HTTPURLResponse(url: url, statusCode: 204,
                                             httpVersion: "HTTP/2.0",
                                             headerFields: nil)!

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
