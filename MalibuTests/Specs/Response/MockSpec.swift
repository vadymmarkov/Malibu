@testable import Malibu
import Quick
import Nimble
import When

final class MockSpec: QuickSpec {
  override func spec() {
    describe("Mock") {
      var mock: Mock!
      let request = TestService.fetchPosts.request
      var httpResponse = HTTPURLResponse(url: URL(string: TestService.baseUrl!.urlString)!,
                                     statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)!
      let data = "test".data(using: String.Encoding.utf32)
      let error = NetworkError.noDataInResponse

      describe("#init:response:data:error") {
        beforeEach {
          mock = Mock(httpResponse: httpResponse, data: data, error: error)
        }

        it("sets properties") {
          expect(mock.httpResponse).to(equal(httpResponse))
          expect(mock.data).to(equal(data))
          expect(mock.error as! NetworkError == error).to(beTrue())
        }
      }

      describe("#init:fileName:bundle") {
        let fileName = "mock.json"
        var response: Response!

        beforeEach {
          mock = Mock(fileName: fileName, bundle: Bundle(for: MockSpec.self))
          httpResponse = HTTPURLResponse(url: URL(string: fileName)!, statusCode: 200,
            httpVersion: "HTTP/2.0", headerFields: nil)!
          response = Response(
            data: mock.data!,
            urlRequest: try! request.toUrlRequest(),
            httpUrlResponse: mock.httpResponse!
          )
        }

        it("sets properties") {
          let contentTypeValidator = ContentTypeValidator(contentTypes: ["application/json"])
          let statusCodeValidator = StatusCodeValidator(statusCodes: [200])
          let serializer = JsonSerializer()
          let dictionary = try! serializer.serialize(response: response) as! [String: String]

          expect(mock.httpResponse?.statusCode).to(equal(httpResponse.statusCode))
          expect(mock.error).to(beNil())
          expect{ try contentTypeValidator.validate(response) }.toNot(throwError())
          expect{ try statusCodeValidator.validate(response) }.toNot(throwError())
          expect(dictionary["first_name"]).to(equal("John"))
          expect(dictionary["last_name"]).to(equal("Hyperseed"))
          expect(dictionary["email"]).to(equal("ios@hyper.no"))
        }
      }

      describe("#init:json") {
        let json = [
          "first_name" : "John",
          "last_name" : "Hyperseed",
          "email" : "ios@hyper.no"
        ]

        var response: Response!

        beforeEach {
          mock = Mock(json: json)
          httpResponse = HTTPURLResponse(
            url: URL(string: "mock://JSON")!,
            statusCode: 200,
            httpVersion: "HTTP/2.0",
            headerFields: nil
          )!
          response = Response(
            data: mock.data!,
            urlRequest: try! request.toUrlRequest(),
            httpUrlResponse: mock.httpResponse!
          )
        }

        it("sets properties") {
          let contentTypeValidator = ContentTypeValidator(contentTypes: ["application/json"])
          let statusCodeValidator = StatusCodeValidator(statusCodes: [200])
          let serializer = JsonSerializer()
          let dictionary = try! serializer.serialize(response: response) as! [String: String]

          expect(mock.httpResponse?.statusCode).to(equal(httpResponse.statusCode))
          expect(mock.error).to(beNil())
          expect{ try contentTypeValidator.validate(response) }.toNot(throwError())
          expect{ try statusCodeValidator.validate(response) }.toNot(throwError())
          expect(dictionary["first_name"]).to(equal("John"))
          expect(dictionary["last_name"]).to(equal("Hyperseed"))
          expect(dictionary["email"]).to(equal("ios@hyper.no"))
        }
      }
    }
  }
}
