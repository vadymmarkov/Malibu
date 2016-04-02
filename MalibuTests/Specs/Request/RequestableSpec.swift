@testable import Malibu
import Quick
import Nimble

class RequestableSpec: QuickSpec {

  override func spec() {
    describe("Requestable") {
      var request: Requestable!

      beforeEach {
        request = POSTRequest(parameters: ["key": "value"], headers: ["key": "value"])
        ETagStorage().clear()
      }

      afterSuite {
        do {
          try NSFileManager.defaultManager().removeItemAtPath(Utils.storageDirectory)
        } catch {}
      }

      describe("#cachePolicy") {
        it("has default value") {
          expect(request.cachePolicy).to(equal(NSURLRequestCachePolicy.UseProtocolCachePolicy))
        }
      }

      describe("#toURLRequest") {
        context("when request URL is invalid") {
          it("throws an error") {
            request.message.resource = "not an URL"
            expect{ try request.toURLRequest() }.to(throwError(Error.InvalidRequestURL))
          }
        }

        context("when parameters encoding fails") {
          it("throws an error") {
            let fakeString = String(bytes: [0xD8, 0x00] as [UInt8],
              encoding: NSUTF16BigEndianStringEncoding)!
            request.message.parameters = ["firstname": fakeString]

            expect{ try request.toURLRequest() }.to(throwError())
          }
        }

        context("when there are no errors") {
          context("without base URL") {
            it("does not throw an error and returns created NSMutableURLRequest") {
              var URLRequest: NSURLRequest!

              expect{ URLRequest = try request.toURLRequest() }.toNot(throwError())
              expect(URLRequest.URL).to(equal(NSURL(string: request.message.resource.URLString)))
              expect(URLRequest.HTTPMethod).to(equal(Method.POST.rawValue))
              expect(URLRequest.cachePolicy).to(equal(request.cachePolicy))
              expect(URLRequest.allHTTPHeaderFields?["Content-Type"]).to(equal(request.contentType.header))
              expect(URLRequest.HTTPBody).to(equal(
                try! parameterEncoders[request.contentType]?.encode(request.message.parameters)))
              expect(URLRequest.allHTTPHeaderFields?["key"]).to(equal("value"))
            }
          }

          context("with base URL") {
            it("does not throw an error and returns created NSMutableURLRequest") {
              var URLRequest: NSURLRequest!
              request.message.resource = "/about"

              expect { URLRequest = try request.toURLRequest("http://hyper.no") }.toNot(throwError())
              expect(URLRequest.URL?.absoluteString).to(equal("http://hyper.no/about"))
            }
          }

          context("with additional headers") {
            it("returns created NSMutableURLRequest with new header added") {
              var URLRequest: NSURLRequest!
              let headers = ["foo": "bar", "key": "bar"]
              request.message.resource = "/about"

              expect { URLRequest = try request.toURLRequest("http://hyper.no", additionalHeaders: headers) }.toNot(throwError())

              expect(URLRequest.allHTTPHeaderFields?["foo"]).to(equal("bar"))
              expect(URLRequest.allHTTPHeaderFields?["key"]).to(equal("value"))
            }
          }

          context("with CachePolicy enabled") {
            beforeEach {
              request = GETRequest(parameters: ["key": "value"], headers: ["key": "value"])
            }

            context("when we have ETag stored") {
              it("adds If-None-Match header") {
                let storage = ETagStorage()
                let etag = "W/\"123456789"

                storage.add(etag, forKey: request.etagKey())

                let URLRequest = try! request.toURLRequest()

                expect(URLRequest.allHTTPHeaderFields?["If-None-Match"]).to(equal(etag))
              }
            }

            context("when we do not have ETag stored") {
              it("does not add If-None-Match header") {
                let URLRequest = try! request.toURLRequest()
                expect(URLRequest.allHTTPHeaderFields?["If-None-Match"]).to(beNil())
              }
            }
          }

          context("with CachePolicy disabled") {
            context("when we have ETag stored") {
              it("does not add If-None-Match header") {
                let storage = ETagStorage()
                let etag = "W/\"123456789"

                storage.add(etag, forKey: request.etagKey())

                let URLRequest = try! request.toURLRequest()


                expect(URLRequest.allHTTPHeaderFields?["If-None-Match"]).to(beNil())
              }
            }

            context("when we do not have ETag stored") {
              it("does not add If-None-Match header") {
                let URLRequest = try! request.toURLRequest()
                expect(URLRequest.allHTTPHeaderFields?["If-None-Match"]).to(beNil())
              }
            }
          }
        }

        describe("#etagKey") {
          it("returns ETag key built from resource and parameters") {
            let result = "\(request.method)\(request.message.resource.URLString)\(request.message.parameters.description)"
            expect(request.etagKey()).to(equal(result))
          }
        }

        describe("#key") {
          it("bulds a description based on rmethod and request URL") {
            expect(request.key).to(equal("POST http://hyper.no"))
          }
        }
      }
    }
  }
}
