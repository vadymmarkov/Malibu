@testable import Malibu
import Quick
import Nimble

class EtagStorageSpec: QuickSpec {

  override func spec() {
    describe("EtagStorage") {
      let filePath = EtagStorage.path
      let value = "value", key = "key"
      var storage: EtagStorage!

      let fileManager = FileManager.default

      beforeEach {
        storage = EtagStorage()
      }

      afterEach {
        do {
          try fileManager.removeItem(atPath: filePath)
        } catch {}
      }

      describe("#addValue:forKey:save") {
        it("adds value to the dictionary") {
          storage.add(value: value, forKey: key)
          expect(storage.get(key)).to(equal(value))

          storage.reload()
          expect(storage.get(key)).to(equal(value))
        }
      }

      describe("#get") {
        context("key exists") {
          it("returns a value") {
            storage.add(value: value, forKey: key)
            expect(storage.get(key)).to(equal(value))
          }
        }

        context("key does not exist") {
          it("returns nil") {
            expect(storage.get(key)).to(beNil())
          }
        }
      }

      describe("#save") {
        it("saves dictionary to the file") {
          storage.add(value: "value", forKey: "key")
          storage.save()

          let exists = FileManager.default.fileExists(atPath: filePath)

          expect(exists).to(beTrue())
        }
      }

      describe("#reload") {
        it("reloads values") {
          storage.add(value: value, forKey: key)
          storage.reload()

          expect(storage.get(key)).to(equal(value))
        }
      }
    }
  }
}
