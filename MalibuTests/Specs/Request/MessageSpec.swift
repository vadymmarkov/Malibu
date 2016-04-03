@testable import Malibu
import Quick
import Nimble

class MessageSpec: QuickSpec {

  override func spec() {
    describe("Message") {
      let resource = "http://hyper.no"
      var message: Message!

      beforeEach {
        message = Message(resource: resource)
      }

      describe("#init") {
        it("sets parameter values") {
          message = Message(resource: resource, parameters: ["key": "value"], headers: ["key": "value"])

          expect(message.resource.URLString).to(equal(resource.URLString))
          expect(message.parameters.count).to(equal(1))
          expect(message.headers).to(equal(["key": "value"]))
        }

        it("is sets default values") {
          expect(message.parameters.isEmpty).to(beTrue())
          expect(message.headers.isEmpty).to(beTrue())
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
        }
      }
    }
  }
}
