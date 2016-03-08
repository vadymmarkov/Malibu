@testable import Malibu
import When
import Quick
import Nimble

class NetworkResultSpec: QuickSpec {

  override func spec() {
    describe("NetworkResult") {
      var networkPromise: Promise<NetworkResult>!
      let URL = NSURL(string: "http://hyper.no")!
      let response = NSHTTPURLResponse(URL: URL, statusCode: 200, HTTPVersion: "HTTP/2.0", headerFields: nil)!
      let failedResponse = NSHTTPURLResponse(URL: URL, statusCode: 404, HTTPVersion: "HTTP/2.0", headerFields: nil)!
      var request: NSURLRequest!
      var data: NSData!

      // MARK: - Helpers

      func testFailedResponse<T>(promise: Promise<T>) {
        let expectation = self.expectationWithDescription("Validation response failure")

        promise.fail({ error in
          expect(error as! Error == Error.NoDataInResponse).to(beTrue())
          expectation.fulfill()
        })

        networkPromise.reject(Error.NoDataInResponse)

        self.waitForExpectationsWithTimeout(4.0, handler:nil)
      }

      func testFailedPromise<T>(promise: Promise<T>, error: Error, response: NSHTTPURLResponse) {
        let expectation = self.expectationWithDescription("Validation response failure")

        promise.fail({ validationError in
          expect(validationError as! Error == error).to(beTrue())
          expectation.fulfill()
        })

        networkPromise.resolve(NetworkResult(data: data, request: request, response: response))

        self.waitForExpectationsWithTimeout(4.0, handler:nil)
      }

      func testSucceededPromise<T>(promise: Promise<T>, response: NSHTTPURLResponse, validation: ((T) -> Void)? = nil) {
        let expectation = self.expectationWithDescription("Validation response success")
        let networkResult = NetworkResult(data: data, request: request, response: response)
        
        promise.done({ result in
          validation?(result)
          expectation.fulfill()
        })

        networkPromise.resolve(networkResult)

        self.waitForExpectationsWithTimeout(4.0, handler:nil)
      }

      // MARK: - Specs

      beforeEach {
        networkPromise = Promise<NetworkResult>()
        request = NSURLRequest(URL: NSURL(string: "http://hyper.no")!)
        data = try! NSJSONSerialization.dataWithJSONObject([["name": "Taylor"]],
          options: NSJSONWritingOptions())
      }

      describe("#init") {
        it("sets data, request and response parameters to instance vars") {
          let result = NetworkResult(data: data, request: request, response: response)

          expect(result.request).to(equal(request))
          expect(result.response).to(equal(response))
        }
      }

      describe("#validate:") {
        let validator = StatusCodeValidator(statusCodes: [200])
        var promise: Promise<NetworkResult>!

        beforeEach {
          promise = networkPromise.validate(validator)
        }

        context("when response is rejected") {
          it("rejects validation promise with an error") {
            testFailedResponse(promise)
          }
        }

        context("when response is resolved and validation fails") {
          it("rejects validation promise with an error") {
            testFailedPromise(promise, error: Error.UnacceptableStatusCode(404),
              response: failedResponse)
          }
        }

        context("when response is resolved and validation succeeded") {
          it("resolves validation response with a result") {
            testSucceededPromise(promise, response: response)
          }
        }
      }

      describe("#validate:statusCodes") {
        var promise: Promise<NetworkResult>!

        beforeEach {
          promise = networkPromise.validate(statusCodes: [200])
        }

        context("when response is rejected") {
          it("rejects validation promise with an error") {
            testFailedResponse(promise)
          }
        }

        context("when response is resolved and validation fails") {
          it("rejects validation promise with an error") {
            testFailedPromise(promise, error: Error.UnacceptableStatusCode(404),
              response: failedResponse)
          }
        }

        context("when response is resolved and validation succeeded") {
          it("resolves validation response with a result") {
            testSucceededPromise(promise, response: response)
          }
        }
      }

      describe("#validate:contentTypes") {
        var promise: Promise<NetworkResult>!

        beforeEach {
          promise = networkPromise.validate(contentTypes: ["application/json; charset=utf-8"])
        }

        context("when response is rejected") {
          it("rejects validation promise with an error") {
            testFailedResponse(promise)
          }
        }

        context("when response is resolved and validation fails") {
          it("rejects validation promise with an error") {
            let response = NSHTTPURLResponse(URL: URL, MIMEType: "text/html; charset=utf-8",
              expectedContentLength: 100, textEncodingName: nil)

            testFailedPromise(promise,
              error: Error.UnacceptableContentType("text/html; charset=utf-8"),
              response: response)
          }
        }

        context("when response is resolved and validation succeeded") {
          it("resolves validation response with a result") {
            let response = NSHTTPURLResponse(URL: URL, MIMEType: "application/json; charset=utf-8",
              expectedContentLength: 100, textEncodingName: nil)
            testSucceededPromise(promise, response: response)
          }
        }
      }

      describe("#validate") {
        var promise: Promise<NetworkResult>!

        context("with no accept header in the request") {
          beforeEach {
            promise = networkPromise.validate()
          }

          context("when response is rejected") {
            it("rejects validation promise with an error") {
              testFailedResponse(promise)
            }
          }

          context("when response is resolved and validation fails") {
            it("rejects validation promise with an error") {
              testFailedPromise(promise, error: Error.UnacceptableStatusCode(404),
                response: failedResponse)
            }
          }

          context("when response is resolved and validation succeeded") {
            it("resolves validation response with a result") {
              testSucceededPromise(promise, response: response)
            }
          }
        }

        context("with accept header in the request") {
          var promise: Promise<NetworkResult>!

          beforeEach {
            let request = NSMutableURLRequest(URL: URL)
            request.addValue("text/html; charset=utf-8", forHTTPHeaderField: "Accept")
            promise = networkPromise.validate()
          }

          context("when response is rejected") {
            it("rejects validation promise with an error") {
              testFailedResponse(promise)
            }
          }

          context("when response is resolved and validation fails") {
            it("rejects validation promise with an error") {
              testFailedPromise(promise, error: Error.UnacceptableStatusCode(404),
                response: failedResponse)
            }
          }

          context("when response is resolved and validation succeeded") {
            it("resolves validation response with a result") {
              let HTTPResponse = NSHTTPURLResponse(URL: URL, statusCode: 200,
                HTTPVersion: "HTTP/2.0", headerFields: nil)!
              HTTPResponse.setValue("text/html; charset=utf-8", forKey: "MIMEType")

              testSucceededPromise(promise, response: response)
            }
          }
        }
      }

      describe("#toJSONArray") {
        var promise: Promise<[[String: AnyObject]]>!

        beforeEach {
          promise = networkPromise.toJSONArray()
        }
        
        context("when response is rejected") {
          it("rejects validation promise with an error") {
            testFailedResponse(promise)
          }
        }
        
        context("when response is resolved and serialization fails") {
          it("rejects serialization promise with an error") {
            data = try! NSJSONSerialization.dataWithJSONObject(["name": "Taylor"],
              options: NSJSONWritingOptions())
            
            testFailedPromise(promise, error: Error.JSONArraySerializationFailed,
              response: failedResponse)
          }
        }
        
        context("when response is resolved and validation succeeded") {
          it("resolves validation response with a result") {
            let array = [["name": "Taylor"]]
            data = try! NSJSONSerialization.dataWithJSONObject(array,
              options: NSJSONWritingOptions())
    
            testSucceededPromise(promise, response: response) { result in
              expect(result).to(equal(array))
            }
          }
        }
      }
      
      describe("#toJSONDictionary") {
        var promise: Promise<[String: AnyObject]>!
        
        beforeEach {
          promise = networkPromise.toJSONDictionary()
        }
        
        context("when response is rejected") {
          it("rejects validation promise with an error") {
            testFailedResponse(promise)
          }
        }
        
        context("when response is resolved and serialization fails") {
          it("rejects serialization promise with an error") {
            data = try! NSJSONSerialization.dataWithJSONObject([["name": "Taylor"]],
              options: NSJSONWritingOptions())
            
            testFailedPromise(promise, error: Error.JSONDictionarySerializationFailed,
              response: failedResponse)
          }
        }
        
        context("when response is resolved and validation succeeded") {
          it("resolves validation response with a result") {
            let dictionary = ["name": "Taylor"]
            data = try! NSJSONSerialization.dataWithJSONObject(dictionary,
              options: NSJSONWritingOptions())
            
            testSucceededPromise(promise, response: response) { result in
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
