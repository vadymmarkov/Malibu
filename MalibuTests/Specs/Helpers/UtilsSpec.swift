@testable import Malibu
import Quick
import Nimble

class UtilsSpec: QuickSpec {

  override func spec() {
    describe("Utils") {
      let fileManager = NSFileManager.defaultManager()

      afterSuite {
        do {
          try fileManager.removeItemAtPath(Utils.storageDirectory)
        } catch {}
      }

      describe(".documentDirectory") {
        it("returns document directory") {
          let documentDirectory =  NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true).first!

          expect(Utils.documentDirectory).to(equal(documentDirectory))
        }
      }

      describe(".storageDirectory") {
        it("returns a test storage directory path") {
          let directory = "\(Utils.documentDirectory)/Malibu"
          var isDir: ObjCBool = true

          expect(Utils.storageDirectory).to(equal(directory))
          expect(fileManager.fileExistsAtPath(Utils.storageDirectory, isDirectory: &isDir)).to(beTrue())
        }
      }

      describe(".filePath") {
        it("returns a full file path") {
          let name = "filename"
          let path = "\(Utils.storageDirectory)/\(name)"

          expect(Utils.filePath(name)).to(equal(path))
        }
      }
    }
  }
}
