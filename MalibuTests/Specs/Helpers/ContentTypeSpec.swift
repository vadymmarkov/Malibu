@testable import Malibu
import Quick
import Nimble

class ContentTypeSpec: QuickSpec {

  override func spec() {
    describe("ContentType") {
      var contentType: ContentType!
      
      context("when it's JSON type") {
        beforeEach {
          contentType = .JSON
        }
        
        describe("#value") {
          it("returns a correct string value") {
            expect(contentType.value).to(equal("application/json"))
          }
        }
        
        describe("#hashValue") {
          it("returns a hash value of corresponding string value") {
            expect(contentType.hashValue).to(equal(contentType.value.hashValue))
          }
        }
        
        describe("#equal") {
          it("compares for value equality") {
            expect(contentType).to(equal(ContentType.JSON))
            expect(contentType).toNot(equal(ContentType.FormURLEncoded))
            expect(contentType).toNot(equal(ContentType.Custom("application/custom")))
          }
        }
      }
      
      context("when it's FormURLEncoded type") {
        beforeEach {
          contentType = .FormURLEncoded
        }
        
        describe("#value") {
          it("returns a correct string value") {
            expect(contentType.value).to(equal("application/x-www-form-urlencoded"))
          }
        }
        
        describe("#hashValue") {
          it("returns a hash value of corresponding string value") {
            expect(contentType.hashValue).to(equal(contentType.value.hashValue))
          }
        }
        
        describe("#equal") {
          it("compares for value equality") {
            expect(contentType).toNot(equal(ContentType.JSON))
            expect(contentType).to(equal(ContentType.FormURLEncoded))
            expect(contentType).toNot(equal(ContentType.Custom("application/custom")))
          }
        }
      }
      
      context("when it's Custom type") {
        beforeEach {
          contentType = .Custom("application/custom")
        }
        
        describe("#value") {
          it("returns a correct string value") {
            expect(contentType.value).to(equal("application/custom"))
          }
        }
        
        describe("#hashValue") {
          it("returns a hash value of corresponding string value") {
            expect(contentType.hashValue).to(equal(contentType.value.hashValue))
          }
        }
        
        describe("#equal") {
          it("compares for value equality") {
            expect(contentType).toNot(equal(ContentType.JSON))
            expect(contentType).toNot(equal(ContentType.FormURLEncoded))
            expect(contentType).to(equal(ContentType.Custom("application/custom")))
          }
        }
      }
    }
  }
}
