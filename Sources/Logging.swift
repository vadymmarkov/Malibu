import Foundation

// MARK: - Logger

public enum LogLevel {
  case None, Error, Info, Verbose
}

public class Logger {

  public var level: LogLevel = .None
  public var errorLogger: ErrorLogging.Type = ErrorLogger.self
  public var requestLogger: RequestLogging.Type = RequestLogger.self
  public var responseLogger: ResponseLogging.Type = ResponseLogger.self

  public var enabled: Bool {
    return level != .None
  }
}

public protocol Logging {
  var level: LogLevel { get }
  init(level: LogLevel)
}

// MARK: - Errors

public protocol ErrorLogging: Logging {
  func logError(error: ErrorType)
}

public struct ErrorLogger: ErrorLogging {

  public let level: LogLevel

  public init(level: LogLevel) {
    self.level = level
  }

  public func logError(error: ErrorType) {
    guard level != .None else {
      return
    }

    print("\(error)")
  }
}

// MARK: - Request

public protocol RequestLogging: Logging {
  func logRequest(request: Requestable, URLRequest: NSURLRequest)
}

public struct RequestLogger: RequestLogging {

  public let level: LogLevel

  public init(level: LogLevel) {
    self.level = level
  }

  public func logRequest(request: Requestable, URLRequest: NSURLRequest) {
    guard let URLString = URLRequest.URL?.absoluteString else {
      return
    }

    guard level == .Info || level == .Verbose else {
      return
    }

    print("🏄 MALIBU: Catching the wave...")
    print("\(request.method.rawValue) \(URLString)")

    guard level == .Verbose else {
      return
    }

    if let headers = URLRequest.allHTTPHeaderFields where !headers.isEmpty {
      print("Headers:")
      print(headers)
    }

    if !request.message.parameters.isEmpty && request.contentType != .Query {
      print("Parameters:")
      print(request.message.parameters)
    }
  }
}

// MARK: - Response

public protocol ResponseLogging: Logging {
  func logResponse(response: NSHTTPURLResponse)
}

public struct ResponseLogger: ResponseLogging {

  public let level: LogLevel

  public init(level: LogLevel) {
    self.level = level
  }

  public  func logResponse(response: NSHTTPURLResponse) {
    guard level == .Info || level == .Verbose else {
      return
    }

    print("Response: \(response.statusCode)")
  }
}
