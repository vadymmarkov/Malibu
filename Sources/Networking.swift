import Foundation
import When

public class Networking {

  enum SessionTaskKind {
    case Data, Upload, Download
  }

  public var additionalHeaders = [String: String]()

  var baseURLString: URLStringConvertible?
  let sessionConfiguration: SessionConfiguration
  var preProcessRequest: (NSMutableURLRequest -> Void)?
  var customHeaders = [String: String]()

  lazy var session: NSURLSession = {
    return NSURLSession(configuration: self.sessionConfiguration.value)
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

  public init(baseURLString: URLStringConvertible? = nil, sessionConfiguration: SessionConfiguration = .Default) {
    self.baseURLString = baseURLString
    self.sessionConfiguration = sessionConfiguration
  }

  // MARK: - Requests

  func execute(method: Method, request: Requestable) -> Promise<NetworkResult> {
    let promise = Promise<NetworkResult>()
    let URLRequest: NSMutableURLRequest

    do {
      URLRequest = try request.toURLRequest(method,
        baseURLString: baseURLString, additionalHeaders: requestHeaders)
    } catch {
      promise.reject(error)
      return promise
    }

    preProcessRequest?(URLRequest)

    session.dataTaskWithRequest(URLRequest, completionHandler: { data, response, error in
      guard let response = response as? NSHTTPURLResponse else {
        promise.reject(Error.NoResponseReceived)
        return
      }

      if let error = error {
        promise.reject(error)
        return
      }

      guard let data = data else {
        promise.reject(Error.NoDataInResponse)
        return
      }

      let result = NetworkResult(data: data, request: URLRequest, response: response)
      promise.resolve(result)
    }).resume()

    return promise
  }

  // MARK: - Authentication

  public func authenticate(username username: String, password: String) {
    guard let header = Header.authentication(username: username, password: password) else {
      return
    }

    customHeaders["Authorization"] = header
  }

  func authenticate(authorizationHeader authorizationHeader: String) {
    customHeaders["Authorization"] = authorizationHeader
  }

  func authenticate(bearerToken bearerToken: String) {
    customHeaders["Authorization"] = "Bearer \(bearerToken)"
  }

  // MARK: - Helpers

  func saveEtag(key: String, response: NSHTTPURLResponse) {
    guard let etag = response.allHeaderFields["ETag"] as? String else {
      return
    }

    ETagStorage().add(etag, forKey: key)
  }
}

// MARK: - Requests

extension Networking {

  func GET(request: Requestable) -> Promise<NetworkResult> {
    return execute(.GET, request: request)
  }

  func POST(request: Requestable) -> Promise<NetworkResult> {
    return execute(.POST, request: request)
  }

  func PUT(request: Requestable) -> Promise<NetworkResult> {
    return execute(.PUT, request: request)
  }

  func PATCH(request: Requestable) -> Promise<NetworkResult> {
    return execute(.PATCH, request: request)
  }

  func DELETE(request: Requestable) -> Promise<NetworkResult> {
    return execute(.DELETE, request: request)
  }

  func HEAD(request: Requestable) -> Promise<NetworkResult> {
    return execute(.HEAD, request: request)
  }
}
