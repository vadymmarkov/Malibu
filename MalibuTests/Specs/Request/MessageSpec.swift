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
        it("sets parameter values") {
          message = Message(resource: resource, parameters: ["key": "value"], headers: ["key": "value"],
            contentType: .FormURLEncoded, cachePolicy: .ReturnCacheDataElseLoad, etagPolicy: .Enabled)

          expect(message.resource.URLString).to(equal(resource.URLString))
          expect(message.contentType).to(equal(ContentType.FormURLEncoded))
          expect(message.cachePolicy).to(equal(NSURLRequestCachePolicy.ReturnCacheDataElseLoad))
          expect(message.etagPolicy).to(equal(Message.ETagPolicy.Enabled))
          expect(message.parameters.count).to(equal(1))
          expect(message.headers).to(equal(["key": "value"]))
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
          expect(message.etagKey()).to(equal(result))
        }
      }

      describe("==") {
        it("equals to idential message") {
          expect(message).to(equal(Message(resource: resource)))
        }

        it("does not equal to different message") {
          expect(message).toNot(equal(Message(resource: "http://google.com")))
          expect(message).toNot(equal(Message(resource: resource, parameters: ["key": "value"])))
          expect(message).toNot(equal(Message(resource: resource, headers: ["key": "value"])))
          expect(message).toNot(equal(Message(resource: resource, contentType: .FormURLEncoded)))
          expect(message).toNot(equal(Message(resource: resource, cachePolicy: .ReturnCacheDataElseLoad)))
          expect(message).toNot(equal(Message(resource: resource, etagPolicy: .Enabled)))
        }
      }
    }
  }
}
