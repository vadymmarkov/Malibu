@testable import Malibu
import Quick
import Nimble

final class MimeTypeSpec: QuickSpec {
  override func spec() {
    describe("MimeType") {
      let contentType = "application/json"
      var mime: MimeType!

      describe(".components") {
        it("extracts MIME components") {
          let string = contentType
          let components = MimeType.components(from: string)

          expect(components.type).to(equal("application"))
          expect(components.subtype).to(equal("json"))
        }
      }

      describe("#init") {
        it("creates MIME type with type and subtype") {
          mime = MimeType(contentType: contentType)

          expect(mime).toNot(beNil())
          expect(mime.type).to(equal("application"))
          expect(mime.subtype).to(equal("json"))
        }
      }

      describe("#matches:to") {
        context("when the current MIME type matches to a passed MIME type") {
          it("is true") {
            mime = MimeType(contentType: contentType)
            let type = MimeType(contentType: contentType)!

            expect(mime.matches(to: type)).to(beTrue())
          }
        }

        context("when the current MIME is */*") {
          it("is true") {
            mime = MimeType(contentType: "*/*")
            let type = MimeType(contentType: contentType)!

            expect(mime.matches(to: type)).to(beTrue())
          }
        }

        context("when the current MIME type does not match to a passed MIME type") {
          it("is false") {
            mime = MimeType(contentType: contentType)
            let type = MimeType(contentType: "text/xml")!

            expect(mime.matches(to: type)).to(beFalse())
          }
        }
      }
    }
  }
}
