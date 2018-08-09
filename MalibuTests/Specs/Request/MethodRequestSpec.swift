@testable import Malibu
import Quick
import Nimble

final class MethodRequestSpec: QuickSpec {
  override func spec() {
    var request: Request!

    describe("GET request") {
      beforeEach {
        request = Request.get("posts")
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
    }

    describe("POST request") {
      beforeEach {
        request = Request.post("posts")
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
    }

    describe("PUT request") {
      beforeEach {
        request = Request.put("posts/1")
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
    }

    describe("PATCH request") {
      beforeEach {
        request = Request.patch("posts/1")
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
    }

    describe("DELETE request") {
      beforeEach {
        request = Request.delete("posts/1")
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
    }

    describe("HEAD request") {
      beforeEach {
        request = Request.head("posts")
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
    }
  }
}
