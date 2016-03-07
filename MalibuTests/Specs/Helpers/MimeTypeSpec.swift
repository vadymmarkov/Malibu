@testable import Malibu
import Quick
import Nimble

class MimeTypeSpec: QuickSpec {

  override func spec() {
    let contentType = "application/json"
    var MIME: MIMEType!

    describe(".components") {
      it("extracts MIME components") {
        let string = contentType
        let components = MIMEType.components(string)

        expect(components.type).to(equal("application"))
        expect(components.subtype).to(equal("json"))
      }
    }

    describe("#init") {
      it("creates MIME type with type and subtype") {
        MIME = MIMEType(contentType: contentType)

        expect(MIME).toNot(beNil())
        expect(MIME.type).to(equal("application"))
        expect(MIME.subtype).to(equal("json"))
      }
    }

    describe("#matches") {
      context("when the current MIME type matches to a passed MIME type") {
        it("is true") {
          MIME = MIMEType(contentType: contentType)
          let type = MIMEType(contentType: contentType)!

          expect(MIME.matches(type)).to(beTrue())
        }
      }

      context("when the current MIME is */*") {
        it("is true") {
          MIME = MIMEType(contentType: "*/*")
          let type = MIMEType(contentType: contentType)!

          expect(MIME.matches(type)).to(beTrue())
        }
      }

      context("when the current MIME type does not match to a passed MIME type") {
        it("is false") {
          MIME = MIMEType(contentType: contentType)
          let type = MIMEType(contentType: "text/xml")!

          expect(MIME.matches(type)).to(beFalse())
        }
      }
    }
  }
}
