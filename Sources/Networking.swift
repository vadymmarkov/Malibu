import Foundation
import When

public class Networking: NSObject {

  enum SessionTaskKind {
    case Data, Upload, Download
  }

  public var additionalHeaders: (() -> [String: String])?
  public var beforeEach: (Requestable -> Requestable)?
  public var preProcessRequest: (NSMutableURLRequest -> Void)?

  var baseURLString: URLStringConvertible?
  let sessionConfiguration: SessionConfiguration
  var customHeaders = [String: String]()
  var mocks = [String: Mock]()

  weak var sessionDelegate: NSURLSessionDelegate?

  lazy var session: NSURLSession = {
    return NSURLSession(
      configuration: self.sessionConfiguration.value,
      delegate: self.sessionDelegate ?? self,
      delegateQueue: nil)
  }()

  var requestHeaders: [String: String] {
    var headers = customHeaders

    headers["Accept-Language"] = Header.acceptLanguage

    let extraHeaders = additionalHeaders?() ?? [:]

    extraHeaders.forEach { key, value in
      headers[key] = value
    }

    return headers
  }

  // MARK: - Initialization

  public init(baseURLString: URLStringConvertible? = nil,
              sessionConfiguration: SessionConfiguration = .Default,
              sessionDelegate: NSURLSessionDelegate? = nil) {
    self.baseURLString = baseURLString
    self.sessionConfiguration = sessionConfiguration
    self.sessionDelegate = sessionDelegate
  }

  // MARK: - Networking

  func execute(request: Requestable) -> Ride {
    let promise = Promise<Wave>()
    let URLRequest: NSMutableURLRequest

    do {
      let request = beforeEach?(request) ?? request
      URLRequest = try request.toURLRequest(baseURLString, additionalHeaders: requestHeaders)
    } catch {
      promise.reject(error)
      return Ride(promise: promise)
    }

    preProcessRequest?(URLRequest)

    let task: TaskRunning

    switch Malibu.mode {
    case .Regular:
      task = SessionDataTask(session: session, URLRequest: URLRequest, promise: promise)
    case .Partial:
      if let mock = prepareMock(request) {
        task = MockDataTask(mock: mock, URLRequest: URLRequest, promise: promise)
      } else {
        task = SessionDataTask(session: session, URLRequest: URLRequest, promise: promise)
      }
    case .Fake:
      guard let mock = prepareMock(request) else {
        promise.reject(Error.NoMockProvided)
        return Ride(promise: promise)
      }

      task = MockDataTask(mock: mock, URLRequest: URLRequest, promise: promise)
    }

    let etagPromise = promise.then { result -> Wave in
      self.saveEtag(request, response: result.response)
      return result
    }

    let ridePromise = Promise<Wave>()

    etagPromise
      .done({ value in
        ridePromise.resolve(value)
      })
      .fail({ error in
        if logger.logErrors {
          logger.errorLogger.logError(error)
        }

        ridePromise.reject(error)
      })

    let ride = task.run()
    ride.promise = ridePromise

    return ride
  }

  // MARK: - Authentication

  public func authenticate(username username: String, password: String) {
    guard let header = Header.authentication(username: username, password: password) else {
      return
    }

    customHeaders["Authorization"] = header
  }

  public func authenticate(authorizationHeader authorizationHeader: String) {
    customHeaders["Authorization"] = authorizationHeader
  }

  public func authenticate(bearerToken bearerToken: String) {
    customHeaders["Authorization"] = "Bearer \(bearerToken)"
  }

  // MARK: - Mocks

  public func register(mock mock: Mock) {
    mocks[mock.request.key] = mock
  }

  func prepareMock(request: Requestable) -> Mock? {
    guard let mock = mocks[request.key] else { return nil }

    mock.request = beforeEach?(mock.request) ?? mock.request

    return mock
  }

  // MARK: - Helpers

  func saveEtag(request: Requestable, response: NSHTTPURLResponse) {
    guard let etag = response.allHeaderFields["ETag"] as? String else {
      return
    }

    let prefix = baseURLString?.URLString ?? ""

    ETagStorage().add(etag, forKey: request.etagKey(prefix))
  }
}

// MARK: - Requests

public extension Networking {

  func GET(request: GETRequestable) -> Ride {
    return execute(request)
  }

  func POST(request: POSTRequestable) -> Ride {
    return execute(request)
  }

  func PUT(request: PUTRequestable) -> Ride {
    return execute(request)
  }

  func PATCH(request: PATCHRequestable) -> Ride {
    return execute(request)
  }

  func DELETE(request: DELETERequestable) -> Ride {
    return execute(request)
  }

  func HEAD(request: HEADRequestable) -> Ride {
    return execute(request)
  }
}

// MARK: - NSURLSessionDelegate

extension Networking: NSURLSessionDelegate {

  public func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
    guard let baseURLString = baseURLString,
      baseURL = NSURL(string: baseURLString.URLString),
      serverTrust = challenge.protectionSpace.serverTrust
      else { return }

    if challenge.protectionSpace.host == baseURL.host {
      completionHandler(
        NSURLSessionAuthChallengeDisposition.UseCredential,
        NSURLCredential(forTrust: serverTrust))
    }
  }
}
