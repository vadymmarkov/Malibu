@testable import Malibu
import Quick
import Nimble

class RequestCapsuleSpec: QuickSpec {

  override func spec() {
    describe("RequestCapsule") {
      var request: Requestable!
      var capsule: RequestCapsule!

      beforeEach {
        request = GETRequest()
        capsule = RequestCapsule(request: request)
      }

      describe("#init") {
        it("sets values") {
          expect(capsule.method).to(equal(request.method))
          expect(capsule.message).to(equal(request.message))
          expect(capsule.contentType).to(equal(request.contentType))
          expect(capsule.etagPolicy).to(equal(request.etagPolicy))
          expect(capsule.storePolicy).to(equal(request.storePolicy))
          expect(capsule.cachePolicy).to(equal(request.cachePolicy))
          expect(capsule.id).to(equal(request.message.resource.urlString))
        }
      }

      describe("#init:coder") {
        it("creates an instance") {
          let data = NSKeyedArchiver.archivedData(withRootObject: capsule)
          let result = NSKeyedUnarchiver.unarchiveObject(with: data) as! RequestCapsule

          expect(result.method).to(equal(capsule.method))
          expect(result.message).to(equal(capsule.message))
          expect(result.contentType).to(equal(capsule.contentType))
          expect(result.etagPolicy).to(equal(capsule.etagPolicy))
          expect(result.storePolicy).to(equal(capsule.storePolicy))
          expect(result.cachePolicy).to(equal(capsule.cachePolicy))
        }
      }
    }
  }
}
