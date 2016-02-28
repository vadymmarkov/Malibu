import Foundation
import When

public enum Error: ErrorType {
  case UnknownResponse
  case NoDataInResponse
}

public class Networking {
  
  enum SessionTaskKind {
    case Data, Upload, Download
  }
  
  let sessionConfiguration: SessionConfiguration
  
  lazy var session: NSURLSession = {
    return NSURLSession(configuration: self.sessionConfiguration.configuration)
  }()
  
  public init(sessionConfiguration: SessionConfiguration = .Default) {
    self.sessionConfiguration = sessionConfiguration
  }
  
  func request(method: Method, URL: NSURL, contentType: ContentType, parameters: [String: AnyObject]?) throws -> Promise<NSData> {
    let promise = Promise<NSData>()
    
    let request = NSMutableURLRequest(URL: URL)
    request.HTTPMethod = method.rawValue
    request.addValue(contentType.value, forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    if let encoder = parameterEncoders[contentType], let parameters = parameters {
      request.HTTPBody = try encoder.encode(parameters)
    }
    
    session.dataTaskWithRequest(request, completionHandler: { data, response, error in
      if let error = error {
        promise.reject(error)
        return
      }
      
      guard let data = data else {
        promise.reject(Error.NoDataInResponse)
        return
      }
      
      promise.resolve(data)
    }).resume()
    
    return promise
  }
}
