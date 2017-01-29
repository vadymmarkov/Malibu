@testable import Malibu
import Quick
import Nimble
import When

class MockOperationSpec: QuickSpec {

  override func spec() {
    describe("MockOperation") {
      var operation: MockOperation!
      var mock: Mock!
      var request: Request!
      var urlRequest: URLRequest!
      var response: HTTPURLResponse!
      var ride: Ride!
      let data = "test".data(using: String.Encoding.utf32)
      let error = NetworkError.jsonArraySerializationFailed

      beforeEach {
        request = TestService.fetchPosts.request
        urlRequest = try! request.toUrlRequest()
        response = HTTPURLResponse(url: URL(string: "http://api.loc")!,
          statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)!
        ride = Ride()
      }

      describe("#init") {
        beforeEach {
          mock = Mock(response: response, data: data, error: error)
          operation = MockOperation(mock: mock, urlRequest: urlRequest, ride: ride)
        }

        it("sets properties") {
          expect(operation.mock === mock).to(beTrue())
          expect(operation.urlRequest).to(equal(urlRequest))
          expect(operation.ride === ride).to(beTrue())
        }
      }

      describe("#execute") {
        context("when response is nil") {
          it("rejects promise with an error") {
            let expectation = self.expectation(description: "No response failure")

            mock = Mock(response: nil, data: data, error: nil)
            operation = MockOperation(mock: mock, urlRequest: urlRequest, ride: ride)

            operation.ride.fail({ error in
              expect(error as! NetworkError == NetworkError.noResponseReceived).to(beTrue())
              expectation.fulfill()
            })

            operation.execute()

            self.waitForExpectations(timeout: 4.0, handler:nil)
          }
        }

        context("when there is an error") {
          it("rejects promise with an error") {
            let expectation = self.expectation(description: "Error failure")

            mock = Mock(response: response, data: data, error: error)
            operation = MockOperation(mock: mock, urlRequest: urlRequest, ride: ride)

            operation.ride.fail({ error in
              expect(error as! NetworkError == NetworkError.jsonArraySerializationFailed).to(beTrue())
              expectation.fulfill()
            })

            operation.execute()

            self.waitForExpectations(timeout: 4.0, handler:nil)
          }
        }

        context("when there is no data") {
          it("rejects promise with an error") {
            let expectation = self.expectation(description: "No data failure")

            mock = Mock(response: response, data: nil, error: nil)
            operation = MockOperation(mock: mock, urlRequest: urlRequest, ride: ride)

            operation.ride.fail({ error in
              expect(error as! NetworkError == NetworkError.noDataInResponse).to(beTrue())
              expectation.fulfill()
            })

            operation.execute()

            self.waitForExpectations(timeout: 4.0, handler:nil)
          }
        }

        context("when validation succeeded") {
          it("resolves promise with a result") {
            let expectation = self.expectation(description: "Validation succeeded")

            mock = Mock(response: response, data: data, error: nil)
            operation = MockOperation(mock: mock, urlRequest: urlRequest, ride: ride)

            operation.ride.done({ result in
              expect(result.data).to(equal(operation.mock.data))
              expect(result.request).to(equal(operation.urlRequest))
              expect(result.response).to(equal(operation.mock.response))

              expectation.fulfill()
            })

            operation.execute()

            self.waitForExpectations(timeout: 4.0, handler:nil)
          }
        }
      }
    }
  }
}
