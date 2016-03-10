@testable import Malibu
import Quick
import Nimble

class MessageSpec: QuickSpec {

  override func spec() {
    describe("Requestable") {
      let resource = "http://hyper.no"
      var message: Message!

      beforeEach {
        message = Message(resource: resource)
      }

      describe("#init") {
        it("sets resource value") {
          expect(message.resource.URLString).to(equal(resource.URLString))
        }

        it("is sets default values") {
          expect(message.contentType).to(equal(ContentType.JSON))
          expect(message.cachePolicy).to(equal(NSURLRequestCachePolicy.UseProtocolCachePolicy))
          expect(message.etagPolicy).to(equal(Message.ETagPolicy.Default))
          expect(message.parameters.isEmpty).to(beTrue())
          expect(message.headers.isEmpty).to(beTrue())
        }
      }

      describe("#etagKey") {
        it("returns ETag key built from resource and parameters") {
          let result = message.resource.URLString + message.parameters.description
          expect(message.etagKey).to(equal(result))
        }
      }
    }
  }
}
