import Foundation

public final class Mock {
  public let httpResponse: HTTPURLResponse?
  public let data: Data?
  public let error: Error?

  // MARK: - Initialization

  public init(httpResponse: HTTPURLResponse?, data: Data?, error: Error? = nil) {
    self.data = data
    self.httpResponse = httpResponse
    self.error = error
  }

  public convenience init(fileName: String, bundle: Bundle = Bundle.main) {
    let url = URL(string: fileName)

    guard let fileURL = url,
      let resource = url?.deletingPathExtension().absoluteString,
      let filePath = bundle.path(forResource: resource, ofType: fileURL.pathExtension),
      let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
      let response = HTTPURLResponse(url: fileURL, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)
      else {
        self.init(httpResponse: nil, data: nil, error: NetworkError.noResponseReceived)
        return
    }

    response.setValue("application/json; charset=utf-8", forKey: "MIMEType")

    self.init(httpResponse: response, data: data, error: nil)
  }

  public convenience init(json: Any) {
    var jsonData: Data?

    do {
      jsonData = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions())
    } catch {}

    guard let url = URL(string: "mock://JSON"), let data = jsonData,
      let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)
      else {
        self.init(httpResponse: nil, data: nil, error: NetworkError.noResponseReceived)
        return
    }

    response.setValue("application/json; charset=utf-8", forKey: "MIMEType")

    self.init(httpResponse: response, data: data, error: nil)
  }
}
