import Foundation

public final class Mock {

  public var request: Request
  public var response: HTTPURLResponse?
  public var data: Data?
  public var error: Error?
  public var delay: Double

  // MARK: - Initialization

  public init(request: Request, response: HTTPURLResponse?,
              data: Data?, error: Error? = nil, delay: Double = 0.0) {
    self.request = request
    self.data = data
    self.response = response
    self.error = error
    self.delay = delay
  }

  public convenience init(request: Request, fileName: String,
                          bundle: Bundle = Bundle.main, delay: Double = 0.0) {
    let url = URL(string: fileName)

    guard let fileURL = url,
      let resource = url?.deletingPathExtension().absoluteString,
      let filePath = bundle.path(forResource: resource, ofType: fileURL.pathExtension),
      let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
      let response = HTTPURLResponse(url: fileURL, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)
      else {
        self.init(request: request, response: nil, data: nil,
                  error: NetworkError.noResponseReceived, delay: delay)
        return
    }

    response.setValue("application/json; charset=utf-8", forKey: "MIMEType")

    self.init(request: request, response: response, data: data, error: nil, delay: delay)
  }

  public convenience init(request: Request, json: [String: Any], delay: Double = 0.0) {
    var jsonData: Data?

    do {
      jsonData = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions())
    } catch {}

    guard let url = URL(string: "mock://JSON"), let data = jsonData,
      let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)
      else {
        self.init(request: request, response: nil, data: nil,
                  error: NetworkError.noResponseReceived, delay: delay)
        return
    }

    response.setValue("application/json; charset=utf-8", forKey: "MIMEType")

    self.init(request: request, response: response, data: data, error: nil, delay: delay)
  }
}
