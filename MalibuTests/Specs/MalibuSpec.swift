@testable import Malibu
import Quick
import Nimble

class MalibuSpec: QuickSpec {

  override func spec() {
    describe("Malibu") {
      describe(".mode") {
        it("is regular by default") {
          expect(Malibu.mode).to(equal(Malibu.Mode.regular))
        }
      }
    }
  }
}
