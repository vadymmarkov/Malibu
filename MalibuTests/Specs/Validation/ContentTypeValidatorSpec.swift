@testable import Malibu
import Quick
import Nimble

class ContentTypeValidatorSpec: QuickSpec {

  override func spec() {
    describe("ContentTypeValidator") {
      describe(".validate") {
        let URL = NSURL(string: "http://hyper.no")!
        let contentType = "application/json; charset=utf-8"
        var validator: ContentTypeValidator<[String]>!

        beforeEach {
          validator = ContentTypeValidator(contentTypes: [contentType])
        }

        context("when response has expected content type") {
          it("does not throw an error") {
            let HTTPResponse = NSHTTPURLResponse(URL: URL, MIMEType: contentType,
              expectedContentLength: 10, textEncodingName: nil)

            expect{ try validator.validate(HTTPResponse) }.toNot(throwError())
          }
        }

        context("when response has not expected content type") {
          it("throws an error") {
            let HTTPResponse = NSHTTPURLResponse(URL: URL, MIMEType: "text/html; charset=utf-8",
              expectedContentLength: 100, textEncodingName: nil)

            expect{ try validator.validate(HTTPResponse) }.to(throwError())
          }
        }
      }
    }
  }
}
