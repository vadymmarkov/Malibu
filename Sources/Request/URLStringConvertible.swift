import Foundation

public protocol URLStringConvertible {
  var urlString: String { get }
}

// MARK: - String

extension String: URLStringConvertible {
  public var urlString: String {
    return self
  }
}

// MARK: - NSURL

extension URL: URLStringConvertible {
  public var urlString: String {
    return absoluteString
  }
}
