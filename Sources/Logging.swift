import Foundation

// MARK: - Logger

public enum LogLevel {
  case none, error, info, verbose
}

public final class Logger {
  /// Use `NSLog` instead of `print`
  public static var showOnDevice = false
  public var level: LogLevel = .none
  public var errorLogger: ErrorLogging.Type = ErrorLogger.self
  public var requestLogger: RequestLogging.Type = RequestLogger.self
  public var responseLogger: ResponseLogging.Type = ResponseLogger.self

  public var enabled: Bool {
    return level != .none
  }
}

public protocol Logging {
  var level: LogLevel { get }
  init(level: LogLevel)
}

// MARK: - Errors

public protocol ErrorLogging: Logging {
  func log(error: Error)
}

public final class ErrorLogger: ErrorLogging {
  public let level: LogLevel

  public init(level: LogLevel) {
    self.level = level
  }

  public func log(error: Error) {
    guard level != .none else {
      return
    }

    logString("\(error)")
  }
}

// MARK: - Request

public protocol RequestLogging: Logging {
  func log(request: Request, urlRequest: URLRequest)
}

public final class RequestLogger: RequestLogging {
  public let level: LogLevel

  public init(level: LogLevel) {
    self.level = level
  }

  public func log(request: Request, urlRequest: URLRequest) {
    guard let urlString = urlRequest.url?.absoluteString else {
      return
    }

    guard level == .info || level == .verbose else {
      return
    }

    logString("🏄 MALIBU: Catching the wave...")
    logString("\(request.method.rawValue) \(urlString)")

    guard level == .verbose else {
      return
    }

    if let headers = urlRequest.allHTTPHeaderFields, !headers.isEmpty {
      logString("Headers:")
      logString("\(headers)")
    }

    if !request.parameters.isEmpty && request.contentType != .query {
      logString("Parameters:")
      logString("\(request.parameters)")
    }
  }
}

// MARK: - Response

public protocol ResponseLogging: Logging {
  func log(response: HTTPURLResponse)
}

public final class ResponseLogger: ResponseLogging {
  public let level: LogLevel

  public init(level: LogLevel) {
    self.level = level
  }

  public func log(response: HTTPURLResponse) {
    guard level == .info || level == .verbose else {
      return
    }

    logString("Response: \(response.statusCode)")
  }
}

private func logString(_ string: String) {
  if Logger.showOnDevice {
    NSLog(string)
  } else {
    print(string)
  }
}
