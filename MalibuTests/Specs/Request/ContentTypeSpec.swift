@testable import Malibu
import Quick
import Nimble

class ContentTypeSpec: QuickSpec {

  override func spec() {
    describe("ContentType") {
      var contentType: ContentType!

      context("when it is a query type") {
        beforeEach {
          contentType = .query
        }

        describe("#init:header") {
          let result = ContentType(header: nil)
          expect(result).to(equal(ContentType.query))
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
            expect(contentType).toNot(equal(ContentType.json))
            expect(contentType).to(equal(ContentType.query))
            expect(contentType).toNot(equal(ContentType.custom("application/custom")))
          }
        }
      }

      context("when it is a formURLEncoded type") {
        beforeEach {
          contentType = .formURLEncoded
        }

        describe("#init:header") {
          let result = ContentType(header: "application/x-www-form-urlencoded")
          expect(result).to(equal(ContentType.formURLEncoded))
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
            expect(contentType).toNot(equal(ContentType.json))
            expect(contentType).to(equal(ContentType.formURLEncoded))
            expect(contentType).toNot(equal(ContentType.custom("application/custom")))
          }
        }
      }

      context("when it is a json type") {
        beforeEach {
          contentType = .json
        }

        describe("#init:header") {
          let result = ContentType(header: "application/json")
          expect(result).to(equal(ContentType.json))
        }

        describe("#value") {
          it("returns a correct string value") {
            expect(contentType.header).to(equal("application/json"))
          }
        }

        describe("#encoder") {
          it("returns a corresponding encoder") {
            expect(contentType.encoder is JsonEncoder).to(beTrue())
          }
        }

        describe("#hashValue") {
          it("returns a hash value of corresponding string value") {
            expect(contentType.hashValue).to(equal(contentType.header?.hashValue))
          }
        }

        describe("#equal") {
          it("compares for value equality") {
            expect(contentType).to(equal(ContentType.json))
            expect(contentType).toNot(equal(ContentType.formURLEncoded))
            expect(contentType).toNot(equal(ContentType.custom("application/custom")))
          }
        }
      }

      context("when it is a multipartFormData type") {
        beforeEach {
          contentType = .multipartFormData
        }

        describe("#init:header") {
          let result = ContentType(header: "multipart/form-data; boundary=\(boundary)")
          expect(result).to(equal(ContentType.multipartFormData))
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
            expect(contentType).to(equal(ContentType.multipartFormData))
            expect(contentType).toNot(equal(ContentType.json))
            expect(contentType).toNot(equal(ContentType.formURLEncoded))
            expect(contentType).toNot(equal(ContentType.custom("application/custom")))
          }
        }
      }

      context("when it is a custom type") {
        beforeEach {
          contentType = .custom("application/custom")
        }

        describe("#init:header") {
          let result = ContentType(header: "application/custom")
          expect(result).to(equal(ContentType.custom("application/custom")))
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
            expect(contentType).toNot(equal(ContentType.json))
            expect(contentType).toNot(equal(ContentType.formURLEncoded))
            expect(contentType).to(equal(ContentType.custom("application/custom")))
          }
        }
      }
    }
  }
}
