@testable import Malibu
import Quick
import Nimble

class MalibuSpec: QuickSpec {

  override func spec() {
    describe("Malibu") {
      let baseURLString = "http://hyper.no"
      let surferNetworking = Networking(baseURLString: baseURLString)
      
      beforeEach {
        Malibu.networkings.removeAll()
        Malibu.register("surfer", networking: surferNetworking)
      }
      
      describe(".methodsWithEtags") {
        it("has GET, PATCH, PUT methods") {
          expect(Malibu.methodsWithEtags).to(equal([.GET, .PATCH, .PUT]))
        }
      }
      
      describe(".mode") {
        it("is regular by default") {
          expect(Malibu.mode).to(equal(Malibu.Mode.Regular))
        }
      }
      
      describe(".parameterEncoders") {
        it("has default encoders for content types") {
          expect(Malibu.parameterEncoders.isEmpty).to(beFalse())
          expect(Malibu.parameterEncoders[.JSON] is JSONParameterEncoder).to(beTrue())
          expect(Malibu.parameterEncoders[.FormURLEncoded] is FormURLEncoder).to(beTrue())
        }
      }
      
      describe(".register:networking") {
        it("adds new networking instance with a name") {
          expect(Malibu.networkings.count).to(equal(1))
          expect(Malibu.networkings["surfer"]?.baseURLString?.URLString).to(equal(baseURLString.URLString))
        }
      }

      describe(".unregister") {
        it("removed a networking instance by name") {
          expect(Malibu.networkings.count).to(equal(1))

          Malibu.unregister("surfer")
          
          expect(Malibu.networkings.count).to(equal(0))
        }
      }
      
      describe("networkingNamed") {
        context("when there is a networking registered with this name") {
          it("returns registered networking") {
            expect(networkingNamed("surfer") === surferNetworking).to(beTrue())
          }
        }
        
        context("when there is no networking registered with this name") {
          it("returns default networking") {
            Malibu.unregister("surfer")
            expect(networkingNamed("surfer") === Malibu.backfootSurfer).to(beTrue())
          }
        }
      }
    }
  }
}
