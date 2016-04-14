@testable import Malibu
import Quick
import Nimble
import When

class MockSpec: QuickSpec {

  override func spec() {
    describe("Mock") {
      var mock: Mock!
      let request = GETRequest()
      var response = NSHTTPURLResponse(URL: NSURL(string: "http://hyper.no")!,
        statusCode: 200, HTTPVersion: "HTTP/2.0", headerFields: nil)!
      let data = "test".dataUsingEncoding(NSUTF32StringEncoding)
      let error = Error.NoDataInResponse

      describe("#init:request:response:data:error") {
        beforeEach {
          mock = Mock(request: request, response: response, data: data, error: error)
        }

        it("sets properties") {
          expect(mock.request.message).to(equal(request.message))
          expect(mock.response).to(equal(response))
          expect(mock.data).to(equal(data))
          expect(mock.error as! Error == error).to(beTrue())
        }
      }

      describe("#init:request:fileName:bundle") {
        let fileName = "mock.json"

        beforeEach {
          mock = Mock(request: request, fileName: fileName, bundle: NSBundle(forClass: MockSpec.self))
          response = NSHTTPURLResponse(URL: NSURL(string: fileName)!, statusCode: 200,
            HTTPVersion: "HTTP/2.0", headerFields: nil)!
        }

        it("sets properties") {
          let serializer = JSONSerializer()
          let dictionary = try! serializer.serialize(mock.data!, response: response) as! [String: String]

          expect(mock.request.message).to(equal(request.message))
          expect(mock.response?.statusCode).to(equal(response.statusCode))
          expect(mock.error).to(beNil())
          expect(dictionary["first_name"]).to(equal("John"))
          expect(dictionary["last_name"]).to(equal("Hyperseed"))
          expect(dictionary["email"]).to(equal("ios@hyper.no"))
        }
      }

      describe("#init:request:JSON") {
        let JSON = [
          "first_name" : "John",
          "last_name" : "Hyperseed",
          "email" : "ios@hyper.no"
        ]

        beforeEach {
          mock = Mock(request: request, JSON: JSON)
          response = NSHTTPURLResponse(URL: NSURL(string: "mock://JSON")!, statusCode: 200,
            HTTPVersion: "HTTP/2.0", headerFields: nil)!
        }

        it("sets properties") {
          let serializer = JSONSerializer()
          let dictionary = try! serializer.serialize(mock.data!, response: response) as! [String: String]

          expect(mock.request.message).to(equal(request.message))
          expect(mock.response?.statusCode).to(equal(response.statusCode))
          expect(mock.error).to(beNil())
          expect(dictionary["first_name"]).to(equal("John"))
          expect(dictionary["last_name"]).to(equal("Hyperseed"))
          expect(dictionary["email"]).to(equal("ios@hyper.no"))
        }
      }
    }
  }
}
