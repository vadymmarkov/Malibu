@testable import Malibu
import When
import Quick
import Nimble

protocol NetworkPromiseSpec {
  var networkPromise: NetworkPromise! { get }
  var request: URLRequest! { get }
  var data: Data! { get }
}

extension NetworkPromiseSpec where Self: QuickSpec {
  func testFailedResponse<T>(_ promise: Promise<T>) {
    let expectation = self.expectation(description: "Validation response failure")

    promise.fail({ error in
      expect(error as! NetworkError == NetworkError.noDataInResponse).to(beTrue())
      expectation.fulfill()
    })

    networkPromise.reject(NetworkError.noDataInResponse)

    self.waitForExpectations(timeout: 4.0, handler:nil)
  }

  func testFailedPromise<T>(_ promise: Promise<T>, error: NetworkError, response: HTTPURLResponse) {
    let expectation = self.expectation(description: "Validation response failure")

    promise.fail({ validationError in
      expect(validationError as! NetworkError == error).to(beTrue())
      expectation.fulfill()
    })

    networkPromise.resolve(Response(data: data, urlRequest: request, httpUrlResponse: response))

    self.waitForExpectations(timeout: 4.0, handler:nil)
  }

  func testSucceededPromise<T>(_ promise: Promise<T>,
                               response: HTTPURLResponse,
                               validation: ((T) -> Void)? = nil) {
    let expectation = self.expectation(description: "Validation response success")
    let response = Response(data: data, urlRequest: request, httpUrlResponse: response)

    promise.done({ response in
      validation?(response)
      expectation.fulfill()
    })

    networkPromise.resolve(response)

    self.waitForExpectations(timeout: 4.0, handler:nil)
  }
}
