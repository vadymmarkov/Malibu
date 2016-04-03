@testable import Malibu
import Quick
import Nimble

class MethodRequestableSpec: QuickSpec {

  override func spec() {
    describe("GETRequestable") {
      var request: GETRequestable!

      beforeEach {
        request = GETRequest()
      }

      describe("#method") {
        it("is .GET") {
          expect(request.method).to(equal(Method.GET))
        }
      }

      describe("#contentType") {
        it("is .Query") {
          expect(request.contentType).to(equal(ContentType.Query))
        }
      }

      describe("#etagPolicy") {
        it("is .Enabled") {
          expect(request.etagPolicy).to(equal(ETagPolicy.Enabled))
        }
      }
    }

    describe("POSTRequestable") {
      var request: POSTRequestable!

      beforeEach {
        request = POSTRequest()
      }

      describe("#method") {
        it("is .POST") {
          expect(request.method).to(equal(Method.POST))
        }
      }

      describe("#contentType") {
        it("is .JSON") {
          expect(request.contentType).to(equal(ContentType.JSON))
        }
      }

      describe("#etagPolicy") {
        it("is .Disabled") {
          expect(request.etagPolicy).to(equal(ETagPolicy.Disabled))
        }
      }
    }

    describe("PUTRequestable") {
      var request: PUTRequestable!

      beforeEach {
        request = PUTRequest()
      }

      describe("#method") {
        it("is .PUT") {
          expect(request.method).to(equal(Method.PUT))
        }
      }

      describe("#contentType") {
        it("is .JSON") {
          expect(request.contentType).to(equal(ContentType.JSON))
        }
      }

      describe("#etagPolicy") {
        it("is .Enabled") {
          expect(request.etagPolicy).to(equal(ETagPolicy.Enabled))
        }
      }
    }

    describe("PATCHRequestable") {
      var request: PATCHRequestable!

      beforeEach {
        request = PATCHRequest()
      }

      describe("#method") {
        it("is .PATCH") {
          expect(request.method).to(equal(Method.PATCH))
        }
      }

      describe("#contentType") {
        it("is .JSON") {
          expect(request.contentType).to(equal(ContentType.JSON))
        }
      }

      describe("#etagPolicy") {
        it("is .Enabled") {
          expect(request.etagPolicy).to(equal(ETagPolicy.Enabled))
        }
      }
    }

    describe("DELETERequestable") {
      var request: DELETERequestable!

      beforeEach {
        request = DELETERequest()
      }

      describe("#method") {
        it("is .DELETE") {
          expect(request.method).to(equal(Method.DELETE))
        }
      }

      describe("#contentType") {
        it("is .Query") {
          expect(request.contentType).to(equal(ContentType.Query))
        }
      }

      describe("#etagPolicy") {
        it("is .Disabled") {
          expect(request.etagPolicy).to(equal(ETagPolicy.Disabled))
        }
      }
    }

    describe("HEADRequestable") {
      var request: HEADRequestable!

      beforeEach {
        request = HEADRequest()
      }

      describe("#method") {
        it("is .HEAD") {
          expect(request.method).to(equal(Method.HEAD))
        }
      }

      describe("#contentType") {
        it("is .Query") {
          expect(request.contentType).to(equal(ContentType.Query))
        }
      }

      describe("#etagPolicy") {
        it("is .Disabled") {
          expect(request.etagPolicy).to(equal(ETagPolicy.Disabled))
        }
      }
    }
  }
}
