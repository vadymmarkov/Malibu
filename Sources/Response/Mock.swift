import Foundation

public class Mock {

  public var request: Requestable
  public var response: NSHTTPURLResponse?
  public var data: NSData?
  public var error: ErrorType?
  public var delay: Double = 1.0

  // MARK: - Initialization

  public init(request: Requestable, response: NSHTTPURLResponse?, data: NSData?, error: ErrorType? = nil) {
    self.request = request
    self.data = data
    self.response = response
    self.error = error
  }

  public convenience init(request: Requestable, fileName: String, bundle: NSBundle = NSBundle.mainBundle()) {
    guard let fileURL = NSURL(string: fileName),
      resource = fileURL.URLByDeletingPathExtension?.absoluteString,
      filePath = bundle.pathForResource(resource, ofType: fileURL.pathExtension),
      data = NSData(contentsOfFile: filePath),
      response = NSHTTPURLResponse(URL: fileURL, statusCode: 200, HTTPVersion: "HTTP/2.0", headerFields: nil)
      else {
        self.init(request: request, response: nil, data: nil, error: Error.NoResponseReceived)
        return
    }

    response.setValue("application/json; charset=utf-8", forKey: "MIMEType")

    self.init(request: request, response: response, data: data, error: nil)
  }

  public convenience init(request: Requestable, JSON: [String: AnyObject]) {
    var JSONData: NSData?

    do {
      JSONData = try NSJSONSerialization.dataWithJSONObject(JSON, options: NSJSONWritingOptions())
    } catch {}

    guard let URL = NSURL(string: "mock://JSON"), data = JSONData,
      response = NSHTTPURLResponse(URL: URL, statusCode: 200, HTTPVersion: "HTTP/2.0", headerFields: nil)
      else {
        self.init(request: request, response: nil, data: nil, error: Error.NoResponseReceived)
        return
    }

    response.setValue("application/json; charset=utf-8", forKey: "MIMEType")

    self.init(request: request, response: response, data: data, error: nil)
  }
}
