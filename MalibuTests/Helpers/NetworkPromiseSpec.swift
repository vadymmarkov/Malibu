@testable import Malibu
import When
import Quick
import Nimble

protocol NetworkPromiseSpec {
  var networkPromise: Ride! { get }
  var request: URLRequest! { get }
  var data: Data! { get }
}

extension NetworkPromiseSpec where Self: QuickSpec {

  func testFailedResponse<T>(_ promise: Promise<T>) {
    let expectation = self.expectation(withDescription: "Validation response failure")

    promise.fail({ error in
      expect(error as! Error == Error.NoDataInResponse).to(beTrue())
      expectation.fulfill()
    })

    networkPromise.reject(Error.NoDataInResponse)

    self.waitForExpectations(withTimeout: 4.0, handler:nil)
  }

  func testFailedPromise<T>(_ promise: Promise<T>, error: Error, response: HTTPURLResponse) {
    let expectation = self.expectation(withDescription: "Validation response failure")

    promise.fail({ validationError in
      expect(validationError as! Error == error).to(beTrue())
      expectation.fulfill()
    })

    networkPromise.resolve(Wave(data: data, request: request, response: response))

    self.waitForExpectations(withTimeout: 4.0, handler:nil)
  }

  func testSucceededPromise<T>(_ promise: Promise<T>, response: HTTPURLResponse, validation: ((T) -> Void)? = nil) {
    let expectation = self.expectation(withDescription: "Validation response success")
    let wave = Wave(data: data, request: request, response: response)

    promise.done({ result in
      validation?(result)
      expectation.fulfill()
    })

    networkPromise.resolve(wave)

    self.waitForExpectations(withTimeout: 4.0, handler:nil)
  }
}
