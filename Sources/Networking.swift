import Foundation
import When

// MARK: - Mode

public enum NetworkingMode {
  case sync, async, limited(Int)
}

// MARK: - Mocks

public final class MockProvider<R: RequestConvertible> {
  let resolver: (R) -> Mock?
  let delay: TimeInterval

  public init(delay: TimeInterval = 0, resolver: @escaping (R) -> Mock?) {
    self.resolver = resolver
    self.delay = delay
  }
}

struct MockBehavior {
  let mock: Mock
  let delay: TimeInterval
}

// MARK: - Networking

public final class Networking<R: RequestConvertible>: NSObject, URLSessionDelegate {
  public var beforeEach: ((Request) -> Request)?
  public var preProcessRequest: ((URLRequest) -> URLRequest)?

  public var middleware: (Promise<Void>) -> Void = { promise in
    promise.resolve(Void())
  }

  let sessionConfiguration: SessionConfiguration
  let mockProvider: MockProvider<R>?
  let queue: OperationQueue

  var customHeaders = [String: String]()
  var requestStorage = RequestStorage()
  var mode: NetworkingMode = .async

  weak var sessionDelegate: URLSessionDelegate?

  lazy var session: URLSession = { [unowned self] in
    let session = URLSession(
      configuration: self.sessionConfiguration.value,
      delegate: self.sessionDelegate ?? self,
      delegateQueue: nil)
    return session
  }()

  var requestHeaders: [String: String] {
    var headers = customHeaders
    headers["Accept-Language"] = Header.acceptLanguage
    let extraHeaders = R.headers

    extraHeaders.forEach { key, value in
      headers[key] = value
    }

    return headers
  }

  // MARK: - Initialization

  public init(mode: NetworkingMode = .async,
              mockProvider: MockProvider<R>? = nil,
              sessionConfiguration: SessionConfiguration = SessionConfiguration.default,
              sessionDelegate: URLSessionDelegate? = nil) {
    self.mockProvider = mockProvider
    self.sessionConfiguration = sessionConfiguration
    self.sessionDelegate = sessionDelegate
    queue = OperationQueue()
    super.init()
    reset(mode: mode)
  }

  public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
    var credential: URLCredential?

    if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
      if let serverTrust = challenge.protectionSpace.serverTrust,
        let urlString = R.baseUrl?.urlString,
        let baseURL = URL(string: urlString) {
        if challenge.protectionSpace.host == baseURL.host {
          disposition = .useCredential
          credential = URLCredential(trust: serverTrust)
        } else {
          disposition = .cancelAuthenticationChallenge
        }
      }
    } else {
      if challenge.previousFailureCount > 0 {
        disposition = .rejectProtectionSpace
      } else {
        credential = session.configuration.urlCredentialStorage?.defaultCredential(
          for: challenge.protectionSpace)

        if credential != nil {
          disposition = .useCredential
        }
      }
    }

    completionHandler(disposition, credential)
  }

  public func resume() {
    queue.isSuspended = false
  }

  public func suspend() {
    queue.isSuspended = true
  }

  func reset(mode: NetworkingMode) {
    self.mode = mode

    switch mode {
    case .sync:
      queue.maxConcurrentOperationCount = 1
    case .async:
      queue.maxConcurrentOperationCount = -1
    case .limited(let count):
      queue.maxConcurrentOperationCount = count
    }
  }
}

// MARK: - Request

extension Networking {
  public func request(_ requestConvertible: R) -> NetworkPromise {
    var mockBehavior: MockBehavior?

    if let mockProvider = mockProvider, let mock = mockProvider.resolver(requestConvertible) {
      mockBehavior = MockBehavior(mock: mock, delay: mockProvider.delay)
    }

    return execute(requestConvertible.request, mockBehavior: mockBehavior)
  }

  public func cancelAllRequests() {
    queue.cancelAllOperations()
  }

  func execute(_ request: Request, mockBehavior: MockBehavior? = nil) -> NetworkPromise {
    let middlewarePromise = Promise<Void>()
    let networkPromise = NetworkPromise()

    middlewarePromise.done({ [weak self] in
      guard let `self` = self else {
        return
      }

      let operation = self.createOperation(request: request, mockBehavior: mockBehavior)
      let responseHandler = ResponseHandler(networkPromise: networkPromise)
      operation.handleResponse = responseHandler.handle(urlRequest:data:urlResponse:error:)

      networkPromise
        .done({ [weak self] response in
          self?.saveEtag(request: request, response: response.httpUrlResponse)
          if logger.enabled {
            logger.requestLogger.init(level: logger.level).log(
              request: request,
              urlRequest: response.urlRequest
            )
            logger.responseLogger.init(level: logger.level).log(response: response.httpUrlResponse)
          }
        })
        .fail(policy: .allErrors, { [weak self] error in
          if case PromiseError.cancelled = error {
            operation.cancel()
            operation.finish()
          }
          self?.handle(error: error, on: request)
        })

      self.queue.addOperation(operation)
    })

    middleware(middlewarePromise)
    return networkPromise
  }

  private func createOperation(request: Request, mockBehavior: MockBehavior?) -> AsynchronousOperation {
    let operation: AsynchronousOperation

    if let mockBehavior = mockBehavior {
      operation = MockOperation(mock: mockBehavior.mock, delay: mockBehavior.delay)
    } else {
      operation = SessionOperation(request.task, session: session)
    }

    operation.makeUrlRequest = { [weak self] in
      guard let `self` = self else {
        throw NetworkError.invalidRequestURL
      }
      let request = self.beforeEach?(request) ?? request
      var urlRequest = try request.toUrlRequest(
        baseUrl: R.baseUrl,
        additionalHeaders: self.requestHeaders
      )
      if let preProcessRequest = self.preProcessRequest {
        urlRequest = preProcessRequest(urlRequest)
      }
      return urlRequest
    }

    return operation
  }
}

// MARK: - Authentication

extension Networking {
  public func authenticate(username: String, password: String) {
    guard let header = Header.authentication(username: username, password: password) else {
      return
    }
    customHeaders["Authorization"] = header
  }

  public func authenticate(authorizationHeader: String) {
    customHeaders["Authorization"] = authorizationHeader
  }

  public func authenticate(bearerToken: String) {
    customHeaders["Authorization"] = "Bearer \(bearerToken)"
  }
}

// MARK: - Helpers

extension Networking {
  func saveEtag(request: Request, response: HTTPURLResponse) {
    let etag = response.allHeaderFields["ETag"] ?? response.allHeaderFields["Etag"]

    if let etag = etag as? String {
      let prefix = R.baseUrl?.urlString ?? ""
      EtagStorage().add(value: etag, forKey: request.etagKey(prefix: prefix))
    }
  }

  func handle(error: Error, on request: Request) {
    if logger.enabled {
      logger.errorLogger.init(level: logger.level).log(error: error)
    }

    if request.storePolicy == StorePolicy.offline && (error as NSError).isOffline {
      requestStorage.save(RequestCapsule(request: request))
    }
  }
}

// MARK: - Replay

extension Networking {
  public func replay() -> NetworkPromise {
    let requests = requestStorage.requests.values
    let currentMode = mode

    reset(mode: .sync)
    let lastNetworkPromise = NetworkPromise()

    for (index, capsule) in requests.enumerated() {
      let isLast = index == requests.count - 1

      execute(capsule.request)
        .done({ value in
          guard isLast else { return }
          lastNetworkPromise.resolve(value)
        })
        .fail({ error in
          guard isLast else { return }
          lastNetworkPromise.reject(error)
        })
        .always({ [weak self] result in
          if isLast {
            self?.reset(mode: currentMode)
          }

          if let error = result.error, (error as NSError).isOffline {
            return
          }

          self?.requestStorage.remove(capsule)
        })
    }

    return lastNetworkPromise
  }
}
