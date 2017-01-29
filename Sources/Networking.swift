import Foundation
import When

public enum NetworkingMode {
  case sync, async, limited(Int)
}

public final class Networking<S: Schema>: NSObject, URLSessionDelegate {

  public var beforeEach: ((Request) -> Request)?
  public var preProcessRequest: ((URLRequest) -> URLRequest)?

  public var middleware: (Promise<Void>) -> Void = { promise in
    promise.resolve()
  }

  var schema: S
  var customHeaders = [String: String]()
  var mocks = [String: Mock]()
  var requestStorage = RequestStorage()
  var mode: NetworkingMode = .async
  let queue: OperationQueue

  weak var sessionDelegate: URLSessionDelegate?

  lazy var session: URLSession = { [unowned self] in
    let session = URLSession(
      configuration: self.schema.sessionConfiguration.value,
      delegate: self.sessionDelegate ?? self,
      delegateQueue: nil)
    return session
  }()

  var requestHeaders: [String: String] {
    var headers = customHeaders
    headers["Accept-Language"] = Header.acceptLanguage
    let extraHeaders = schema.headers

    extraHeaders.forEach { key, value in
      headers[key] = value
    }

    return headers
  }

  // MARK: - Initialization

  public init(schema: S,
              mode: NetworkingMode = .async,
              sessionConfiguration: SessionConfiguration = .default,
              sessionDelegate: URLSessionDelegate? = nil) {
    self.schema = schema
    self.sessionDelegate = sessionDelegate

    queue = OperationQueue()
    super.init()
    reset(mode: mode)
  }

  // MARK: - Mode

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

  // MARK: - Networking

  func start(_ request: Request) -> Ride {
    let ride = Ride()
    var urlRequest: URLRequest

    do {
      let request = beforeEach?(request) ?? request
      urlRequest = try request.toUrlRequest(baseUrl: schema.baseUrl, additionalHeaders: requestHeaders)
    } catch {
      ride.reject(error)
      return ride
    }

    if let preProcessRequest = preProcessRequest {
      urlRequest = preProcessRequest(urlRequest)
    }

    guard let operation = buildOperation(ride: ride, request: request, urlRequest: urlRequest)
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

  public func request(_ endpoint: S.EndpointType) -> Ride {
    return execute(endpoint.request)
  }

  func execute(_ request: Request) -> Ride {
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

  func buildOperation(ride: Ride, request: Request, urlRequest: URLRequest) -> ConcurrentOperation? {
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

  func prepareMock(for request: Request) -> Mock? {
    guard let mock = mocks[request.key] else { return nil }

    mock.request = beforeEach?(mock.request) ?? mock.request

    return mock
  }

  // MARK: - Helpers

  func saveEtag(request: Request, response: HTTPURLResponse) {
    guard let etag = response.allHeaderFields["ETag"] as? String else {
      return
    }

    let prefix = schema.baseUrl.urlString

    EtagStorage().add(value: etag, forKey: request.etagKey(prefix: prefix))
  }

  func handle(error: Error, on request: Request) {
    guard request.storePolicy == StorePolicy.offline && (error as NSError).isOffline else {
      return
    }

    requestStorage.save(RequestCapsule(request: request))
  }

  public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    guard
      let baseURL = NSURL(string: schema.baseUrl.urlString),
      let serverTrust = challenge.protectionSpace.serverTrust
      else { return }

    if challenge.protectionSpace.host == baseURL.host {
      completionHandler(
        URLSession.AuthChallengeDisposition.useCredential,
        URLCredential(trust: serverTrust))
    }
  }
}

// MARK: - Requests

public extension Networking {

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

    for (index, capsule) in requests.enumerated() {
      let isLast = index == requests.count - 1

      execute(capsule.request)
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

          self?.requestStorage.remove(capsule)
        })
    }

    return lastRide
  }
}
