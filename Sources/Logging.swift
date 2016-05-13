import Foundation

// MARK: - Errors

public protocol ErrorLogging {
  func logError(error: ErrorType)
}

public struct ErrorLogger: ErrorLogging {

  public func logError(error: ErrorType) {
    NSLog("\(error)")
  }
}

// MARK: - Info

public protocol InfoLogging {
  func logRequest(request: NSURLRequest)
}

public struct InfoLogger: InfoLogging {

  public func logRequest(request: NSURLRequest) {
    guard let URLString = request.URL?.absoluteString else {
      return
    }

    NSLog("\(URLString)")
  }
}
