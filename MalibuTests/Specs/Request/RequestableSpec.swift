@testable import Malibu
import Quick
import Nimble

class RequestableSpec: QuickSpec {

  override func spec() {
    describe("Requestable") {
      var request: Request!
      var urlRequest: URLRequest!

      beforeEach {
        request = Request.post(
          resource: "http://api.loc/posts",
          parameters: ["key": "value"],
          headers: ["key": "value"])

        EtagStorage().clear()
      }

      afterSuite {
        do {
          try FileManager.default.removeItem(atPath: Utils.storageDirectory)
        } catch {}
      }

      describe("#storePolicy") {
        it("has default value") {
          expect(request.storePolicy).to(equal(StorePolicy.unspecified))
        }
      }

      describe("#cachePolicy") {
        it("has default value") {
          expect(request.cachePolicy).to(equal(NSURLRequest.CachePolicy.useProtocolCachePolicy))
        }
      }

      describe("#toURLRequest") {
        context("when request URL is invalid") {
          it("throws an error") {
            request = Request.post(resource: "not an URL")
            expect{ try request.toUrlRequest() }.to(throwError(NetworkError.invalidRequestURL))
          }
        }

        context("when there are no errors") {
          context("without base URL") {
            it("does not throw an error and returns created URLRequest") {
              expect { urlRequest = try request.toUrlRequest() }.toNot(throwError())
              expect(urlRequest.url).to(equal(URL(string: request.resource.urlString)))
              expect(urlRequest.httpMethod).to(equal(Method.post.rawValue))
              expect(urlRequest.cachePolicy).to(equal(request.cachePolicy))
              expect(urlRequest.allHTTPHeaderFields?["Content-Type"]).to(equal(request.contentType.header))
              expect(urlRequest.httpBody).to(
                equal(try! request.contentType.encoder?.encode(parameters: request.parameters)))
              expect(urlRequest.allHTTPHeaderFields?["key"]).to(equal("value"))
            }
          }

          context("with base URL") {
            it("does not throw an error and returns created URLRequest") {
              request = Request.post(resource: "/about")

              expect {
                urlRequest = try request.toUrlRequest(baseUrl: "http://api.loc")
              }.toNot(throwError())
              expect(urlRequest.url?.absoluteString).to(equal("http://api.loc/about"))
            }
          }

          context("with base URL with slash") {
            it("does not throw an error and returns created URLRequest") {
              request = Request.post(resource: "/about")

              expect {
                urlRequest = try request.toUrlRequest(baseUrl: "http://api.loc/")
                }.toNot(throwError())
              expect(urlRequest.url?.absoluteString).to(equal("http://api.loc/about"))
            }
          }

          context("with base URL without slash") {
            it("does not throw an error and returns created URLRequest") {
              request = Request.post(resource: "about")

              expect {
                urlRequest = try request.toUrlRequest(baseUrl: "http://api.loc")
                }.toNot(throwError())
              expect(urlRequest.url?.absoluteString).to(equal("http://api.loc/about"))
            }
          }

          context("with additional headers") {
            it("returns created URLRequest with new header added") {
              let headers = ["foo": "bar", "key": "bar"]
              request = Request.post(resource: "/about", headers: ["key": "value"])

              expect {
                urlRequest = try request.toUrlRequest(
                baseUrl: "http://hyper.no",
                additionalHeaders: headers)
              }.toNot(throwError())

              expect(urlRequest.allHTTPHeaderFields?["foo"]).to(equal("bar"))
              expect(urlRequest.allHTTPHeaderFields?["key"]).to(equal("value"))
            }
          }

          context("with ETagPolicy enabled") {
            beforeEach {
              request = Request.get(
                resource: "http:/api.loc/posts",
                parameters: ["key": "value"],
                headers: ["key": "value"])
            }

            context("when we have ETag stored") {
              it("adds If-None-Match header") {
                let storage = EtagStorage()
                let etag = "W/\"123456789"

                storage.add(value: etag, forKey: request.etagKey())

                let urlRequest = try! request.toUrlRequest()

                expect(urlRequest.allHTTPHeaderFields?["If-None-Match"]).to(equal(etag))
              }
            }

            context("when we do not have ETag stored") {
              it("does not add If-None-Match header") {
                let urlRequest = try! request.toUrlRequest()
                expect(urlRequest.allHTTPHeaderFields?["If-None-Match"]).to(beNil())
              }
            }
          }

          context("with ETagPolicy disabled") {
            beforeEach {
              request = Request.post(
                resource: "http:/api.loc/posts",
                parameters: ["key": "value"],
                headers: ["key": "value"])
            }

            context("when we have ETag stored") {
              it("does not add If-None-Match header") {
                let storage = EtagStorage()
                let etag = "W/\"123456789"

                storage.add(value: etag, forKey: request.etagKey())

                let urlRequest = try! request.toUrlRequest()

                expect(urlRequest.allHTTPHeaderFields?["If-None-Match"]).to(beNil())
              }
            }

            context("when we do not have ETag stored") {
              it("does not add If-None-Match header") {
                let urlRequest = try! request.toUrlRequest()
                expect(urlRequest.allHTTPHeaderFields?["If-None-Match"]).to(beNil())
              }
            }
          }

          context("with Query content type") {
            beforeEach {
              request = Request.get(
                resource: "http:/api.loc/posts",
                parameters: ["key": "value", "number": 1])
            }

            it("does not set Content-Type header") {
              expect{ urlRequest = try request.toUrlRequest() }.toNot(throwError())
              expect(urlRequest.allHTTPHeaderFields?["Content-Type"]).to(beNil())
            }

            it("does not set body") {
              expect{ urlRequest = try request.toUrlRequest() }.toNot(throwError())
              expect(urlRequest.httpBody).to(beNil())
            }
          }

          context("with MultipartFormData content type") {
            beforeEach {
              request = Request.post(
                resource: "http:/api.loc/posts",
                contentType: .multipartFormData,
                parameters: ["key": "value", "number": 1])
            }

            it("sets Content-Type header") {
              expect{ urlRequest = try request.toUrlRequest() }.toNot(throwError())
              expect(urlRequest.allHTTPHeaderFields?["Content-Type"]).to(
                equal("multipart/form-data; boundary=\(boundary)")
              )
            }

            it("sets Content-Length header") {
              expect{ urlRequest = try request.toUrlRequest() }.toNot(throwError())
              expect(urlRequest.allHTTPHeaderFields?["Content-Length"]).to(
                equal("\(urlRequest.httpBody!.count)")
              )
            }
          }
        }

        describe("#buildURL") {
          context("when request URL is invalid") {
            it("throws an error") {
              expect {
                try request.buildUrl(from: "not an URL")
              }.to(throwError(NetworkError.invalidRequestURL))
            }
          }

          context("when content type is not Query") {
            beforeEach {
              request = Request.post(
                resource: "http:/api.loc/posts",
                parameters: ["key": "value"])
            }

            it("returns URL") {
              let urlString = "http://hyper.no"
              let result = URL(string: urlString)
              expect(try! request.buildUrl(from: urlString)).to(equal(result))
            }
          }

          context("when content type is Query but there are no parameters") {
            beforeEach {
              request = Request.get(resource: "http:/api.loc/posts")
            }

            it("returns URL") {
              let urlString = "http://hyper.no"
              let result = URL(string: urlString)

              expect(try! request.buildUrl(from: urlString)).to(equal(result))
            }
          }

          context("when content type is Query and request has parameters") {
            beforeEach {
              request = Request.get(
                resource: "http:/api.loc/posts",
                parameters: ["key": "value", "number": 1])
            }

            it("returns URL") {
              let urlString = "http://hyper.no"
              let result1 = URL(string: "http://hyper.no?key=value&number=1")
              let result2 = URL(string: "http://hyper.no?number=1&key=value")
              let url = try! request.buildUrl(from: urlString)

              expect(url == result1 || url == result2).to(beTrue())
            }
          }
        }

        describe("#etagKey") {
          it("returns ETag key built from method, prefix, resource and parameters") {
            let result = "\(request.method.rawValue)\(request.resource.urlString)\(request.parameters.description)"
            expect(request.etagKey()).to(equal(result))
          }
        }

        describe("#key") {
          it("bulds a description based on rmethod and request URL") {
            expect(request.key).to(equal("POST http://api.loc/posts"))
          }
        }
      }
    }
  }
}
