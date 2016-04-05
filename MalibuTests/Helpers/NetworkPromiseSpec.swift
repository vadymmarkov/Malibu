@testable import Malibu
import When
import Quick
import Nimble

protocol NetworkPromiseSpec {
  var networkPromise: Promise<Wave>! { get }
  var request: NSURLRequest! { get }
  var data: NSData! { get }
}

extension NetworkPromiseSpec where Self: QuickSpec {

  func testFailedResponse<T>(promise: Promise<T>) {
    let expectation = self.expectationWithDescription("Validation response failure")

    promise.fail({ error in
      expect(error as! Error == Error.NoDataInResponse).to(beTrue())
      expectation.fulfill()
    })

    networkPromise.reject(Error.NoDataInResponse)

    self.waitForExpectationsWithTimeout(4.0, handler:nil)
  }

  func testFailedPromise<T>(promise: Promise<T>, error: Error, response: NSHTTPURLResponse) {
    let expectation = self.expectationWithDescription("Validation response failure")

    promise.fail({ validationError in
      expect(validationError as! Error == error).to(beTrue())
      expectation.fulfill()
    })

    networkPromise.resolve(Wave(data: data, request: request, response: response))

    self.waitForExpectationsWithTimeout(4.0, handler:nil)
  }

  func testSucceededPromise<T>(promise: Promise<T>, response: NSHTTPURLResponse, validation: ((T) -> Void)? = nil) {
    let expectation = self.expectationWithDescription("Validation response success")
    let wave = Wave(data: data, request: request, response: response)

    promise.done({ result in
      validation?(result)
      expectation.fulfill()
    })

    networkPromise.resolve(wave)

    self.waitForExpectationsWithTimeout(4.0, handler:nil)
  }
}
