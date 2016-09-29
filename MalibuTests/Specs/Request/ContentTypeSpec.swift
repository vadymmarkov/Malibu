@testable import Malibu
import Quick
import Nimble

class ContentTypeSpec: QuickSpec {

  override func spec() {
    describe("ContentType") {
      var contentType: ContentType!

      context("when it is Query type") {
        beforeEach {
          contentType = .Query
        }

        describe("init:header") {
          let result = ContentType(header: nil)
          expect(result).to(equal(ContentType.Query))
        }

        describe("#value") {
          it("returns nil") {
            expect(contentType.header).to(beNil())
          }
        }

        describe("#encoder") {
          it("returns nil") {
            expect(contentType.encoder).to(beNil())
          }
        }

        describe("#hashValue") {
          it("returns a hash value") {
            expect(contentType.hashValue).to(equal("query".hashValue))
          }
        }

        describe("#equal") {
          it("compares for value equality") {
            expect(contentType).toNot(equal(ContentType.JSON))
            expect(contentType).to(equal(ContentType.Query))
            expect(contentType).toNot(equal(ContentType.Custom("application/custom")))
          }
        }
      }

      context("when it is FormURLEncoded type") {
        beforeEach {
          contentType = .FormURLEncoded
        }

        describe("init:header") {
          let result = ContentType(header: "application/x-www-form-urlencoded")
          expect(result).to(equal(ContentType.FormURLEncoded))
        }

        describe("#value") {
          it("returns a correct string value") {
            expect(contentType.header).to(equal("application/x-www-form-urlencoded"))
          }
        }

        describe("#encoder") {
          it("returns a corresponding encoder") {
            expect(contentType.encoder is FormURLEncoder).to(beTrue())
          }
        }

        describe("#hashValue") {
          it("returns a hash value of corresponding string value") {
            expect(contentType.hashValue).to(equal(contentType.header?.hashValue))
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

      context("when it is JSON type") {
        beforeEach {
          contentType = .JSON
        }

        describe("init:header") {
          let result = ContentType(header: "application/json")
          expect(result).to(equal(ContentType.JSON))
        }

        describe("#value") {
          it("returns a correct string value") {
            expect(contentType.header).to(equal("application/json"))
          }
        }

        describe("#encoder") {
          it("returns a corresponding encoder") {
            expect(contentType.encoder is JSONEncoder).to(beTrue())
          }
        }

        describe("#hashValue") {
          it("returns a hash value of corresponding string value") {
            expect(contentType.hashValue).to(equal(contentType.header?.hashValue))
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

      context("when it is MultipartFormData type") {
        beforeEach {
          contentType = .MultipartFormData
        }

        describe("init:header") {
          let result = ContentType(header: "multipart/form-data; boundary=\(boundary)")
          expect(result).to(equal(ContentType.MultipartFormData))
        }

        describe("#value") {
          it("returns a correct string value") {
            expect(contentType.header).to(equal("multipart/form-data; boundary=\(boundary)"))
          }
        }

        describe("#encoder") {
          it("returns a corresponding encoder") {
            expect(contentType.encoder is MultipartFormEncoder).to(beTrue())
          }
        }

        describe("#hashValue") {
          it("returns a hash value of corresponding string value") {
            expect(contentType.hashValue).to(equal(contentType.header?.hashValue))
          }
        }

        describe("#equal") {
          it("compares for value equality") {
            expect(contentType).to(equal(ContentType.MultipartFormData))
            expect(contentType).toNot(equal(ContentType.JSON))
            expect(contentType).toNot(equal(ContentType.FormURLEncoded))
            expect(contentType).toNot(equal(ContentType.Custom("application/custom")))
          }
        }
      }

      context("when it is Custom type") {
        beforeEach {
          contentType = .Custom("application/custom")
        }

        describe("init:header") {
          let result = ContentType(header: "application/custom")
          expect(result).to(equal(ContentType.Custom("application/custom")))
        }

        describe("#value") {
          it("returns a correct string value") {
            expect(contentType.header).to(equal("application/custom"))
          }
        }

        describe("#encoder") {
          it("returns nil") {
            expect(contentType.encoder).to(beNil())
          }
        }

        describe("#hashValue") {
          it("returns a hash value of corresponding string value") {
            expect(contentType.hashValue).to(equal(contentType.header?.hashValue))
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
