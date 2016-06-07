@testable import Malibu
import When
import Quick
import Nimble

class WaveSerializationSpec: QuickSpec, NetworkPromiseSpec {

  var networkPromise: Ride!
  var request: NSURLRequest!
  var data: NSData!

  override func spec() {
    describe("WaveSerialization") {

      let URL = NSURL(string: "http://hyper.no")!
      let response = NSHTTPURLResponse(URL: URL, statusCode: 200, HTTPVersion: "HTTP/2.0", headerFields: nil)!

      // MARK: - Specs

      beforeEach {
        self.networkPromise = Ride()
        self.request = NSURLRequest(URL: NSURL(string: "http://hyper.no")!)
        self.data = try! NSJSONSerialization.dataWithJSONObject([["name": "Taylor"]],
          options: NSJSONWritingOptions())
      }

      describe("#toString") {
        var promise: Promise<String>!

        beforeEach {
          promise = self.networkPromise.toString(NSUTF8StringEncoding)
        }

        context("when response is rejected") {
          it("rejects promise with an error") {
            self.testFailedResponse(promise)
          }
        }

        context("when response is resolved") {
          context("when serialization fails") {
            it("rejects promise with an error") {
              self.data = "string".dataUsingEncoding(NSUTF32StringEncoding)

              self.testFailedPromise(promise, error: Error.StringSerializationFailed(NSUTF8StringEncoding),
                response: response)
            }
          }

          context("when there is no data in response") {
            it("rejects promise with an error") {
              self.data = NSData()

              self.testFailedPromise(promise, error: Error.NoDataInResponse,
                response: response)
            }
          }

          context("when response status code is 204 No Content") {
            it("resolves promise with an empty string") {
              self.data = NSData()
              let response = NSHTTPURLResponse(URL: URL, statusCode: 204, HTTPVersion: "HTTP/2.0", headerFields: nil)!

              self.testSucceededPromise(promise, response: response) { result in
                expect(result.isEmpty).to(beTrue())
              }
            }
          }

          context("when serialization succeeded") {
            it("resolves promise with a result") {
              let string = "string"
              self.data = string.dataUsingEncoding(NSUTF8StringEncoding)

              self.testSucceededPromise(promise, response: response) { result in
                expect(result == string).to(beTrue())
              }
            }
          }
        }
      }

      describe("#toJSONArray") {
        var promise: Promise<[[String: AnyObject]]>!

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
              self.data = try! NSJSONSerialization.dataWithJSONObject(["name": "Taylor"],
                options: NSJSONWritingOptions())

              self.testFailedPromise(promise, error: Error.JSONArraySerializationFailed,
                response: response)
            }
          }

          context("when there is no data in response") {
            it("rejects promise with an error") {
              self.data = NSData()

              self.testFailedPromise(promise, error: Error.NoDataInResponse,
                response: response)
            }
          }

          context("when response status code is 204 No Content") {
            it("resolves promise with an empty array") {
              self.data = NSData()
              let response = NSHTTPURLResponse(URL: URL, statusCode: 204, HTTPVersion: "HTTP/2.0", headerFields: nil)!

              self.testSucceededPromise(promise, response: response) { result in
                expect(result).to(equal([]))
              }
            }
          }

          context("when serialization succeeded") {
            it("resolves promise with a result") {
              let array = [["name": "Taylor"]]
              self.data = try! NSJSONSerialization.dataWithJSONObject(array,
                options: NSJSONWritingOptions())

              self.testSucceededPromise(promise, response: response) { result in
                expect(result).to(equal(array))
              }
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
          it("rejects promise with an error") {
            self.testFailedResponse(promise)
          }
        }

        context("when response is resolved") {
          context("when serialization fails") {
            it("rejects promise with an error") {
              self.data = try! NSJSONSerialization.dataWithJSONObject([["name": "Taylor"]],
                options: NSJSONWritingOptions())

              self.testFailedPromise(promise, error: Error.JSONDictionarySerializationFailed,
                response: response)
            }
          }

          context("when there is no data in response") {
            it("rejects promise with an error") {
              self.data = NSData()

              self.testFailedPromise(promise, error: Error.NoDataInResponse,
                response: response)
            }
          }

          context("when response status code is 204 No Content") {
            it("resolves promise with an empty dictionary") {
              self.data = NSData()
              let response = NSHTTPURLResponse(URL: URL, statusCode: 204, HTTPVersion: "HTTP/2.0", headerFields: nil)!

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
}
