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

  func request(method: Method, URL: NSURL, contentType: ContentType = .JSON, parameters: [String: AnyObject] = [:]) throws -> Response<ResponseResult<NSData>> {
    let promise = Response<ResponseResult<NSData>>()

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
        promise.reject(ResponseError(error: error, request: request, response: response))
        return
      }

      guard let data = data else {
        promise.reject(ResponseError(error: Error.NoDataInResponse, request: request, response: response))
        return
      }

      let result = ResponseResult(data: data, request: request, response: response)

      promise.resolve(result)
    }).resume()

    return promise
  }
}
