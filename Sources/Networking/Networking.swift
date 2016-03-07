import Foundation
import When

public class Networking {

  enum SessionTaskKind {
    case Data, Upload, Download
  }

  let sessionConfiguration: SessionConfiguration

  lazy var session: NSURLSession = {
    return NSURLSession(configuration: self.sessionConfiguration.value)
  }()

  public init(sessionConfiguration: SessionConfiguration = .Default) {
    self.sessionConfiguration = sessionConfiguration
  }

  func request(method: Method, URL: NSURL, contentType: ContentType = .JSON, parameters: [String: AnyObject] = [:]) throws -> Promise<NetworkResult> {
    let promise = Promise<NetworkResult>()

    let request = NSMutableURLRequest(URL: URL)
    request.HTTPMethod = method.rawValue
    request.addValue(contentType.value, forHTTPHeaderField: "Content-Type")

    if let encoder = parameterEncoders[contentType] {
      request.HTTPBody = try encoder.encode(parameters)
    }

    session.dataTaskWithRequest(request, completionHandler: { data, response, error in
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

      let result = NetworkResult(data: data, request: request, response: response)
      promise.resolve(result)
    }).resume()

    return promise
  }
}
