import Foundation
import When

public final class Networking: NSObject {

  enum SessionTaskKind {
    case data, upload, download
  }

  public enum Mode {
    case sync, async, limited(Int)
  }

  public var additionalHeaders: (() -> [String: String])?
  public var beforeEach: ((Requestable) -> Requestable)?
  public var preProcessRequest: ((NSMutableURLRequest) -> Void)?

  public var middleware: (Promise<Void>) -> Void = { promise in
    promise.resolve()
  }

  var baseUrl: URLStringConvertible?
  let sessionConfiguration: SessionConfiguration
  var customHeaders = [String: String]()
  var mocks = [String: Mock]()
  var requestStorage = RequestStorage()
  var mode: Mode = .async
  let queue: OperationQueue

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

    let extraHeaders = additionalHeaders?() ?? [:]

    extraHeaders.forEach { key, value in
      headers[key] = value
    }

    return headers
  }

  // MARK: - Initialization

  public init(baseUrl: URLStringConvertible? = nil,
              mode: Mode = .async,
              sessionConfiguration: SessionConfiguration = .default,
              sessionDelegate: URLSessionDelegate? = nil) {
    self.baseUrl = baseUrl
    self.sessionConfiguration = sessionConfiguration
    self.sessionDelegate = sessionDelegate

    queue = OperationQueue()
    super.init()
    reset(mode: mode)
  }

  // MARK: - Mode

  func reset(mode: Mode) {
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

  // MARK: - Networking

  func start(_ request: Requestable) -> Ride {
    let ride = Ride()
    let urlRequest: NSMutableURLRequest

    do {
      let request = beforeEach?(request) ?? request
      urlRequest = try request.toUrlRequest(baseUrl: baseUrl, additionalHeaders: requestHeaders)
    } catch {
      ride.reject(error)
      return ride
    }

    preProcessRequest?(urlRequest)

    guard let operation = buildOperation(ride: ride, request: request, urlRequest: urlRequest as URLRequest)
      else {
        return ride
    }


    let etagPromise = ride.then { [weak self] result -> Wave in
      self?.saveEtag(request: request, response: result.response)
      return result
    }

    let nextRide = Ride()

    etagPromise
      .done({ value in
        if logger.enabled {
          logger.requestLogger.init(level: logger.level).log(request: request, urlRequest: value.request)
          logger.responseLogger.init(level: logger.level).log(response: value.response)
        }

        nextRide.resolve(value)
      })
      .fail({ [weak self] error in
        if logger.enabled {
          logger.errorLogger.init(level: logger.level).log(error: error)
        }

        self?.handle(error: error, on: request)
        nextRide.reject(error)
      })

    queue.addOperation(operation)

    return nextRide
  }

  func execute(_ request: Requestable) -> Ride {
    let ride = Ride()
    let beforePromise = Promise<Void>()

    beforePromise
      .then({
        return self.start(request)
      })
      .done({ wave in
        ride.resolve(wave)
      })
      .fail({ error in
        ride.reject(error)
      })

    middleware(beforePromise)

    return ride
  }

  func buildOperation(ride: Ride, request: Requestable, urlRequest: URLRequest) -> ConcurrentOperation? {
    var operation: ConcurrentOperation?

    switch Malibu.mode {
    case .regular:
      operation = DataOperation(session: session, urlRequest: urlRequest, ride: ride)
    case .partial:
      if let mock = prepareMock(for: request) {
        operation = MockOperation(mock: mock, urlRequest: urlRequest, ride: ride)
      } else {
        operation = DataOperation(session: session, urlRequest: urlRequest, ride: ride)
      }
    case .fake:
      guard let mock = prepareMock(for: request) else {
        ride.reject(NetworkError.noMockProvided)
        break
      }

      operation = MockOperation(mock: mock, urlRequest: urlRequest, ride: ride)
    }

    return operation
  }

  // MARK: - Authentication

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

  // MARK: - Mocks

  public func register(mock: Mock) {
    mocks[mock.request.key] = mock
  }

  func prepareMock(for request: Requestable) -> Mock? {
    guard let mock = mocks[request.key] else { return nil }

    mock.request = beforeEach?(mock.request) ?? mock.request

    return mock
  }

  // MARK: - Helpers

  func saveEtag(request: Requestable, response: HTTPURLResponse) {
    guard let etag = response.allHeaderFields["ETag"] as? String else {
      return
    }

    let prefix = baseUrl?.urlString ?? ""

    EtagStorage().add(value: etag, forKey: request.etagKey(prefix: prefix))
  }

  func handle(error: Error, on request: Requestable) {
    guard request.storePolicy == StorePolicy.offline && (error as NSError).isOffline else {
      return
    }

    requestStorage.save(RequestCapsule(request: request))
  }
}

// MARK: - Requests

public extension Networking {

  func GET(_ request: GETRequestable) -> Ride {
    return execute(request)
  }

  func POST(_ request: POSTRequestable) -> Ride {
    return execute(request)
  }

  func PUT(_ request: PUTRequestable) -> Ride {
    return execute(request)
  }

  func PATCH(_ request: PATCHRequestable) -> Ride {
    return execute(request)
  }

  func DELETE(_ request: DELETERequestable) -> Ride {
    return execute(request)
  }

  func HEAD(_ request: HEADRequestable) -> Ride {
    return execute(request)
  }

  func cancelAllRequests() {
    queue.cancelAllOperations()
  }
}

// MARK: - Replay

extension Networking {

  public func replay() -> Ride {
    let requests = requestStorage.requests.values
    let currentMode = mode

    reset(mode: .sync)

    let lastRide = Ride()

    for (index, request) in requests.enumerated() {
      let isLast = index == requests.count - 1

      execute(request)
        .done({ value in
          guard isLast else { return }
          lastRide.resolve(value)
        })
        .fail({ error in
          guard isLast else { return }
          lastRide.reject(error)
        })
        .always({ [weak self] result in
          if isLast {
            self?.reset(mode: currentMode)
          }

          if let error = result.error, (error as NSError).isOffline {
            return
          }

          self?.requestStorage.remove(request)
        })
    }

    return lastRide
  }
}

// MARK: - NSURLSessionDelegate

extension Networking: URLSessionDelegate {

  public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    guard let baseUrl = baseUrl,
      let baseURL = NSURL(string: baseUrl.urlString),
      let serverTrust = challenge.protectionSpace.serverTrust
      else { return }

    if challenge.protectionSpace.host == baseURL.host {
      completionHandler(
        URLSession.AuthChallengeDisposition.useCredential,
        URLCredential(trust: serverTrust))
    }
  }
}
