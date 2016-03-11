@testable import Malibu
import Quick
import Nimble

class RequestableSpec: QuickSpec {

  override func spec() {
    describe("Requestable") {
      var request: Requestable!

      beforeEach {
        request = TestRequest(parameters: ["key": "value"], headers: ["key": "value"])
        ETagStorage().clear()
      }

      afterSuite {
        do {
          try NSFileManager.defaultManager().removeItemAtPath(Utils.storageDirectory)
        } catch {}
      }

      describe("#init") {
        it("sets parameters to the message") {
          expect(request.message.parameters.count).to(equal(1))
          expect(request.message.parameters["key"] as? String).to(equal("value"))
        }

        it("sets headers to the message") {
          expect(request.message.headers.count).to(equal(1))
          expect(request.message.headers["key"]).to(equal("value"))
        }
      }

      describe("#toURLRequest") {
        context("when request URL is invalid") {
          it("throws an error") {
            request.message.resource = "not an URL"
            expect{ try request.toURLRequest(.GET) }.to(throwError(Error.InvalidRequestURL))
          }
        }

        context("when parameters encoding fails") {
          it("throws an error") {
            let fakeString = String(bytes: [0xD8, 0x00] as [UInt8],
              encoding: NSUTF16BigEndianStringEncoding)!
            request.message.parameters = ["firstname": fakeString]

            expect{ try request.toURLRequest(.GET) }.to(throwError())
          }
        }

        context("when there are no errors") {
          it("does not throw an error and returns created NSMutableURLRequest") {
            var URLRequest: NSURLRequest!

            expect{ URLRequest = try request.toURLRequest(.GET) }.toNot(throwError())
            expect(URLRequest.URL).to(equal(NSURL(string: request.message.resource.URLString)))
            expect(URLRequest.HTTPMethod).to(equal(Method.GET.rawValue))
            expect(URLRequest.cachePolicy).to(equal(request.message.cachePolicy))
            expect(URLRequest.allHTTPHeaderFields?["Content-Type"]).to(equal(request.message.contentType.value))
            expect(URLRequest.HTTPBody).to(equal(
              try! parameterEncoders[request.message.contentType]?.encode(request.message.parameters)))
            expect(URLRequest.allHTTPHeaderFields?["key"]).to(equal("value"))
          }

          context("GET request") {
            context("when we have ETag stored") {
              it("adds If-None-Match header") {
                let storage = ETagStorage()
                let etag = "W/\"123456789"

                storage.add(etag, forKey: request.message.etagKey)

                let URLRequest = try! request.toURLRequest(.GET)

                expect(URLRequest.allHTTPHeaderFields?["If-None-Match"]).to(equal(etag))
              }
            }

            context("when we have ETag stored, but etag policy is set to disabled") {
              it("does not add If-None-Match header") {
                request.message.etagPolicy = .Disabled
                let storage = ETagStorage()
                let etag = "W/\"123456789"

                storage.add(etag, forKey: request.message.etagKey)

                let URLRequest = try! request.toURLRequest(.GET)

                expect(URLRequest.allHTTPHeaderFields?["If-None-Match"]).to(beNil())
              }
            }

            context("when we do not have ETag stored") {
              it("does not add If-None-Match header") {
                let URLRequest = try! request.toURLRequest(.GET)
                expect(URLRequest.allHTTPHeaderFields?["If-None-Match"]).to(beNil())
              }
            }
          }

          context("POST request") {
            context("when we have ETag stored") {
              it("does not add If-None-Match header") {
                let storage = ETagStorage()
                let etag = "W/\"123456789"

                storage.add(etag, forKey: request.message.etagKey)

                let URLRequest = try! request.toURLRequest(.POST)


                expect(URLRequest.allHTTPHeaderFields?["If-None-Match"]).to(beNil())
              }
            }

            context("when we have ETag stored and etag policy is set to enabled") {
              it("adds If-None-Match header") {
                request.message.etagPolicy = .Enabled
                let storage = ETagStorage()
                let etag = "W/\"123456789"

                storage.add(etag, forKey: request.message.etagKey)

                let URLRequest = try! request.toURLRequest(.POST)

                expect(URLRequest.allHTTPHeaderFields?["If-None-Match"]).to(equal(etag))
              }
            }

            context("when we do not have ETag stored") {
              it("does not add If-None-Match header") {
                let URLRequest = try! request.toURLRequest(.POST)
                expect(URLRequest.allHTTPHeaderFields?["If-None-Match"]).to(beNil())
              }
            }
          }
        }
      }
    }
  }
}
