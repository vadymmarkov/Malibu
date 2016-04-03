@testable import Malibu
import Quick
import Nimble
import When

class MockDataSpec: QuickSpec {

  override func spec() {
    describe("MockDataTask") {
      var task: MockDataTask!
      var mock: Mock!
      var request: Requestable!
      var URLRequest: NSURLRequest!
      var response: NSHTTPURLResponse!
      var promise: Promise<NetworkResult>!
      let data = "test".dataUsingEncoding(NSUTF32StringEncoding)
      let error = Error.JSONArraySerializationFailed

      beforeEach {
        request = GETRequest()
        URLRequest = try! request.toURLRequest()
        response = NSHTTPURLResponse(URL: NSURL(string: "http://hyper.no")!,
          statusCode: 200, HTTPVersion: "HTTP/2.0", headerFields: nil)!
        promise = Promise<NetworkResult>()
      }

      describe("#init") {
        beforeEach {
          mock = Mock(request: request, response: response, data: data, error: error)
          task = MockDataTask(mock: mock, URLRequest: URLRequest, promise: promise)
        }

        it("sets properties") {
          expect(task.mock === mock).to(beTrue())
          expect(task.URLRequest).to(equal(URLRequest))
          expect(task.promise === promise).to(beTrue())
        }
      }

      describe("#run") {
        context("when response is nil") {
          it("rejects promise with an error") {
            let expectation = self.expectationWithDescription("No response failure")

            mock = Mock(request: request, response: nil, data: data, error: nil)
            task = MockDataTask(mock: mock, URLRequest: URLRequest, promise: promise)

            task.promise.fail({ error in
              expect(error as! Error == Error.NoResponseReceived).to(beTrue())
              expectation.fulfill()
            })

            task.run()

            self.waitForExpectationsWithTimeout(4.0, handler:nil)
          }
        }

        context("when there is an error") {
          it("rejects promise with an error") {
            let expectation = self.expectationWithDescription("Error failure")

            mock = Mock(request: request, response: response, data: data, error: error)
            task = MockDataTask(mock: mock, URLRequest: URLRequest, promise: promise)

            task.promise.fail({ error in
              expect(error as! Error == Error.JSONArraySerializationFailed).to(beTrue())
              expectation.fulfill()
            })

            task.run()

            self.waitForExpectationsWithTimeout(4.0, handler:nil)
          }
        }

        context("when there is no data") {
          it("rejects promise with an error") {
            let expectation = self.expectationWithDescription("No data failure")

            mock = Mock(request: request, response: response, data: nil, error: nil)
            task = MockDataTask(mock: mock, URLRequest: URLRequest, promise: promise)

            task.promise.fail({ error in
              expect(error as! Error == Error.NoDataInResponse).to(beTrue())
              expectation.fulfill()
            })

            task.run()

            self.waitForExpectationsWithTimeout(4.0, handler:nil)
          }
        }

        context("when validation succeeded") {
          it("resolves promise with a result") {
            let expectation = self.expectationWithDescription("Validation succeeded")

            mock = Mock(request: request, response: response, data: data, error: nil)
            task = MockDataTask(mock: mock, URLRequest: URLRequest, promise: promise)

            task.promise.done({ result in
              expect(result.data).to(equal(task.mock.data))
              expect(result.request).to(equal(task.URLRequest))
              expect(result.response).to(equal(task.mock.response))

              expectation.fulfill()
            })

            task.run()

            self.waitForExpectationsWithTimeout(4.0, handler:nil)
          }
        }
      }
    }
  }
}
