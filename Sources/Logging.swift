import Foundation

// MARK: - Logger

public class Logger {

  public enum Level {
    case Debug, Info, Error, Disabled
  }

  public var level: Level = .Disabled
  public var errorLogger: ErrorLogging = ErrorLogger()
  public var infoLogger: InfoLogging = InfoLogger()

  var logErrors: Bool {
    return level == .Error || level == .Debug
  }

  var logInfo: Bool {
    return level == .Info || level == .Debug
  }
}

// MARK: - Errors

public protocol ErrorLogging {
  func logError(error: ErrorType)
}

public struct ErrorLogger: ErrorLogging {

  public func logError(error: ErrorType) {
    print("\(error)")
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

    print("\(URLString)")
  }
}
