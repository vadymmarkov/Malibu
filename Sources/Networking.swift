import Foundation
import When

public class Networking {

  enum SessionTaskKind {
    case Data, Upload, Download
  }

  var baseURLString: URLStringConvertible?
  let sessionConfiguration: SessionConfiguration
  var preProcessRequest: (NSMutableURLRequest -> Void)?

  lazy var session: NSURLSession = {
    return NSURLSession(configuration: self.sessionConfiguration.value)
  }()

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
      URLRequest = try request.toURLRequest(method)
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

  func get(request: Requestable) -> Promise<NetworkResult> {
    return execute(.GET, request: request)
  }

  func post(request: Requestable) -> Promise<NetworkResult> {
    return execute(.POST, request: request)
  }

  func put(request: Requestable) -> Promise<NetworkResult> {
    return execute(.PUT, request: request)
  }

  func patch(request: Requestable) -> Promise<NetworkResult> {
    return execute(.PATCH, request: request)
  }

  func delete(request: Requestable) -> Promise<NetworkResult> {
    return execute(.DELETE, request: request)
  }

  func head(request: Requestable) -> Promise<NetworkResult> {
    return execute(.HEAD, request: request)
  }
}
