@testable import Malibu
import When
import Quick
import Nimble

class NetworkResultSerializationSpec: QuickSpec, NetworkPromiseSpec {

  var networkPromise: Promise<NetworkResult>!
  var request: NSURLRequest!
  var data: NSData!

  override func spec() {
    describe("NetworkResultSerialization") {

      let URL = NSURL(string: "http://hyper.no")!
      let response = NSHTTPURLResponse(URL: URL, statusCode: 200, HTTPVersion: "HTTP/2.0", headerFields: nil)!
      let failedResponse = NSHTTPURLResponse(URL: URL, statusCode: 404, HTTPVersion: "HTTP/2.0", headerFields: nil)!

      // MARK: - Specs

      beforeEach {
        self.networkPromise = Promise<NetworkResult>()
        self.request = NSURLRequest(URL: NSURL(string: "http://hyper.no")!)
        self.data = try! NSJSONSerialization.dataWithJSONObject([["name": "Taylor"]],
          options: NSJSONWritingOptions())
      }

      describe("#toJSONArray") {
        var promise: Promise<[[String: AnyObject]]>!

        beforeEach {
          promise = self.networkPromise.toJSONArray()
        }

        context("when response is rejected") {
          it("rejects validation promise with an error") {
            self.testFailedResponse(promise)
          }
        }

        context("when response is resolved and serialization fails") {
          it("rejects serialization promise with an error") {
            self.data = try! NSJSONSerialization.dataWithJSONObject(["name": "Taylor"],
              options: NSJSONWritingOptions())

            self.testFailedPromise(promise, error: Error.JSONArraySerializationFailed,
              response: failedResponse)
          }
        }

        context("when response is resolved and validation succeeded") {
          it("resolves validation response with a result") {
            let array = [["name": "Taylor"]]
            self.data = try! NSJSONSerialization.dataWithJSONObject(array,
              options: NSJSONWritingOptions())

            self.testSucceededPromise(promise, response: response) { result in
              expect(result).to(equal(array))
            }
          }
        }
      }

      describe("#toJSONDictionary") {
        var promise: Promise<[String: AnyObject]>!

        beforeEach {
          promise = self.networkPromise.toJSONDictionary()
        }

        context("when response is rejected") {
          it("rejects validation promise with an error") {
            self.testFailedResponse(promise)
          }
        }

        context("when response is resolved and serialization fails") {
          it("rejects serialization promise with an error") {
            self.data = try! NSJSONSerialization.dataWithJSONObject([["name": "Taylor"]],
              options: NSJSONWritingOptions())

            self.testFailedPromise(promise, error: Error.JSONDictionarySerializationFailed,
              response: failedResponse)
          }
        }

        context("when response is resolved and validation succeeded") {
          it("resolves validation response with a result") {
            let dictionary = ["name": "Taylor"]
            self.data = try! NSJSONSerialization.dataWithJSONObject(dictionary,
              options: NSJSONWritingOptions())

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
