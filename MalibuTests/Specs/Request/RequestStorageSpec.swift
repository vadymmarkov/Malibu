@testable import Malibu
import Quick
import Nimble

class RequestStorageSpec: QuickSpec {

  override func spec() {
    describe("RequestStorage") {
      let name = "Test"
      var storage: RequestStorage!

      beforeEach {
        storage = RequestStorage(name: name)
      }

      afterEach {
        storage.clear()
      }

      describe("#init") {
        it("sets values") {
          expect(storage.key).to(equal("\(RequestStorage.domain).\(name)"))
        }
      }

      describe("#save") {
        it("saves a capsule") {
          let capsule = RequestCapsule(request: TestService.fetchPosts.request)
          storage.save(capsule)

          expect(storage.requests.count).to(equal(1))
          expect(storage.requests[capsule.id]).toNot(beNil())
          expect(storage.load().count).to(equal(1))
          expect(storage.load()[capsule.id]).toNot(beNil())
        }
      }

      describe("#saveAll") {
        it("saves all capsules") {
          let capsule1 = RequestCapsule(request: TestService.fetchPosts.request)
          let capsule2 = RequestCapsule(request: TestService.showPost(id: 1).request)
          storage.requests["id1"] = capsule1
          storage.requests["id2"] = capsule2

          storage.saveAll()

          expect(storage.requests.count).to(equal(2))
          expect(storage.load().count).to(equal(2))
        }
      }

      describe("#remove") {
        it("removes a capsule") {
          let capsule = RequestCapsule(request: TestService.fetchPosts.request)
          storage.save(capsule)

          expect(storage.requests.count).to(equal(1))
          expect(storage.load().count).to(equal(1))

          storage.remove(capsule)

          expect(storage.requests.count).to(equal(0))
          expect(storage.load().count).to(equal(0))
        }
      }

      describe("#clear") {
        it("removes all capsules") {
          let capsule = RequestCapsule(request: TestService.fetchPosts.request)
          storage.save(capsule)

          expect(storage.requests.count).to(equal(1))
          expect(storage.load().count).to(equal(1))

          storage.clear()

          expect(storage.requests.count).to(equal(0))
          expect(storage.load().count).to(equal(0))
        }
      }

      describe("#clearAll") {
        it("removes all capsules from every storage") {
          var storage2 = RequestStorage()
          let capsule = RequestCapsule(request: TestService.fetchPosts.request)

          storage.save(capsule)
          storage2.save(capsule)

          expect(storage.requests.count).to(equal(1))
          expect(storage.load().count).to(equal(1))
          expect(storage2.requests.count).to(equal(1))
          expect(storage2.load().count).to(equal(1))

          RequestStorage.clearAll()

          storage = RequestStorage(name: name)
          storage2 = RequestStorage()

          expect(storage.requests.count).to(equal(0))
          expect(storage.load().count).to(equal(0))
          expect(storage2.requests.count).to(equal(0))
          expect(storage2.load().count).to(equal(0))
        }
      }

      describe("#load") {
        it("loads capsules") {
          let capsule = RequestCapsule(request: TestService.fetchPosts.request)
          storage.save(capsule)

          expect(storage.requests.count).to(equal(1))
          expect(storage.load().count).to(equal(1))

          storage = RequestStorage(name: name)

          expect(storage.requests.count).to(equal(1))
          expect(storage.load().count).to(equal(1))
        }
      }
    }
  }
}
