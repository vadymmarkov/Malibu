import Foundation

// MARK: - Errors

protocol ErrorLogging {
  func logError(error: ErrorType)
}

struct ErrorLogger: ErrorLogging {

  func logError(error: ErrorType) {
    NSLog("\(error)")
  }
}

// MARK: - Requests

protocol RequestLogging {
  func logRequest(request: NSURLRequest)
}

struct RequestLogger: RequestLogging {

  func logRequest(request: NSURLRequest) {
    guard let URLString = request.URL?.absoluteString else {
      return
    }

    NSLog("\(URLString)")
  }
}
