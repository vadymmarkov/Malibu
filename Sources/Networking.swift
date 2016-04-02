import Foundation
import When

public class Networking: NSObject {

  enum SessionTaskKind {
    case Data, Upload, Download
  }

  public var additionalHeaders = [String: String]()
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

    additionalHeaders.forEach { key, value in
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

  func execute(request: Requestable) -> Promise<NetworkResult> {
    let promise = Promise<NetworkResult>()
    let URLRequest: NSMutableURLRequest

    do {
      URLRequest = try request.toURLRequest(baseURLString, additionalHeaders: requestHeaders)
    } catch {
      promise.reject(error)
      return promise
    }

    preProcessRequest?(URLRequest)

    let task: NetworkTaskRunning

    switch Malibu.mode {
    case .Regular:
      task = SessionDataTask(session: session, URLRequest: URLRequest, promise: promise)
    case .Fake:
      guard let mock = mocks[request.key] else {
        promise.reject(Error.NoMockProvided)
        return promise
      }

      task = MockDataTask(mock: mock, URLRequest: URLRequest, promise: promise)
    }

    let nextPromise = promise.then { result -> NetworkResult in
      self.saveEtag(request, response: result.response)
      return result
    }

    task.run()

    return nextPromise
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

  func register(mock mock: Mock) {
    mocks[mock.request.key] = mock
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

  func GET(request: GETRequestable) -> Promise<NetworkResult> {
    return execute(request)
  }

  func POST(request: POSTRequestable) -> Promise<NetworkResult> {
    return execute(request)
  }

  func PUT(request: PUTRequestable) -> Promise<NetworkResult> {
    return execute(request)
  }

  func PATCH(request: PATCHRequestable) -> Promise<NetworkResult> {
    return execute(request)
  }

  func DELETE(request: DELETERequestable) -> Promise<NetworkResult> {
    return execute(request)
  }

  func HEAD(request: HEADRequestable) -> Promise<NetworkResult> {
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
