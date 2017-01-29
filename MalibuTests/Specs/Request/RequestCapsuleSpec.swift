@testable import Malibu
import Quick
import Nimble

class RequestCapsuleSpec: QuickSpec {

  override func spec() {
    describe("RequestCapsule") {
      var request: Request!
      var capsule: RequestCapsule!

      beforeEach {
        request = TestEndpoint.fetchPosts.request
        capsule = RequestCapsule(request: request)
      }

      describe("#init") {
        it("sets values") {
          expect(capsule.request).to(equal(request))
          expect(capsule.id).to(equal(request.resource.urlString))
        }
      }

      describe("#init:coder") {
        it("creates an instance") {
          let data = NSKeyedArchiver.archivedData(withRootObject: capsule)
          let result = NSKeyedUnarchiver.unarchiveObject(with: data) as! RequestCapsule

          expect(result.request).to(equal(capsule.request))
        }
      }
    }
  }
}
