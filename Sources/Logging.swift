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

    print("============================================")
    print("\(request.method.rawValue) \(URLString)")

    if level == .Verbose {
      logDictionary(request.message.parameters)
      logDictionary(request.message.headers)
    }
  }

  func logDictionary(dictionary: [String: AnyObject]) {
    guard let data = try? NSJSONSerialization.dataWithJSONObject(dictionary, options: .PrettyPrinted),
      string = NSString(data: data, encoding: NSUTF8StringEncoding)
      else {
        return
      }

    print(string)
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

    print("Response status code: \(response.statusCode)")
    print("============================================")
  }
}
