@testable import Malibu
import Quick
import Nimble

class JSONParameterEncoderSpec: QuickSpec {
  
  override func spec() {
    describe("JSONParameterEncoder") {
      var encoder: JSONParameterEncoder!
      
      beforeEach {
        encoder = JSONParameterEncoder()
      }
      
      describe("#encode") {
        it("encodes a dictionary of parameters to NSData object") {
          let parameters = ["firstname": "John", "lastname": "Hyperseed"]
          let data = try! NSJSONSerialization.dataWithJSONObject(parameters,
            options: NSJSONWritingOptions())
          
          expect{ try encoder.encode(parameters) }.to(equal(data))
        }
        
        it("throws an error if the object will not produce valid JSON") {
          let fakeString = String(bytes: [0xD8, 0x00] as [UInt8],
            encoding: NSUTF16BigEndianStringEncoding)!
          let parameters = ["firstname": fakeString]
          
          expect{ try encoder.encode(parameters) }.to(throwError())
        }
      }
    }
  }
}
