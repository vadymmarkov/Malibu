@testable import Malibu
import Quick
import Nimble

class ContentTypeSpec: QuickSpec {

  override func spec() {
    describe("ContentType") {
      var contentType: ContentType!
      
      describe("#value") {
        it("returns correct value for JSON type") {
          contentType = .JSON
          expect(contentType.value).to(equal("application/json"))
        }
        
        it("returns correct value for FormURLEncoded type") {
          contentType = .FormURLEncoded
          expect(contentType.value).to(equal("application/x-www-form-urlencoded"))
        }
        
        it("returns correct value for Custom type") {
          contentType = .Custom("application/custom")
          expect(contentType.value).to(equal("application/custom"))
        }
      }
    }
  }
}
