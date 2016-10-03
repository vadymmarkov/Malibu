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
        it("is .get") {
          expect(request.method).to(equal(Method.get))
        }
      }

      describe("#contentType") {
        it("is .query") {
          expect(request.contentType).to(equal(ContentType.query))
        }
      }

      describe("#etagPolicy") {
        it("is .enabled") {
          expect(request.etagPolicy).to(equal(EtagPolicy.enabled))
        }
      }
    }

    describe("POSTRequestable") {
      var request: POSTRequestable!

      beforeEach {
        request = POSTRequest()
      }

      describe("#method") {
        it("is .post") {
          expect(request.method).to(equal(Method.post))
        }
      }

      describe("#contentType") {
        it("is .JSON") {
          expect(request.contentType).to(equal(ContentType.json))
        }
      }

      describe("#etagPolicy") {
        it("is .disabled") {
          expect(request.etagPolicy).to(equal(EtagPolicy.disabled))
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
          expect(request.method).to(equal(Method.put))
        }
      }

      describe("#contentType") {
        it("is .JSON") {
          expect(request.contentType).to(equal(ContentType.json))
        }
      }

      describe("#etagPolicy") {
        it("is .Enabled") {
          expect(request.etagPolicy).to(equal(EtagPolicy.enabled))
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
          expect(request.method).to(equal(Method.patch))
        }
      }

      describe("#contentType") {
        it("is .JSON") {
          expect(request.contentType).to(equal(ContentType.json))
        }
      }

      describe("#etagPolicy") {
        it("is .Enabled") {
          expect(request.etagPolicy).to(equal(EtagPolicy.enabled))
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
          expect(request.method).to(equal(Method.delete))
        }
      }

      describe("#contentType") {
        it("is .Query") {
          expect(request.contentType).to(equal(ContentType.query))
        }
      }

      describe("#etagPolicy") {
        it("is .Disabled") {
          expect(request.etagPolicy).to(equal(EtagPolicy.disabled))
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
          expect(request.method).to(equal(Method.head))
        }
      }

      describe("#contentType") {
        it("is .Query") {
          expect(request.contentType).to(equal(ContentType.query))
        }
      }

      describe("#etagPolicy") {
        it("is .Disabled") {
          expect(request.etagPolicy).to(equal(EtagPolicy.disabled))
        }
      }
    }
  }
}
