import Foundation

public protocol URLStringConvertible {
  var URLString: String { get }
}

// MARK: - String

extension String: URLStringConvertible {

  public var URLString: String {
    return self
  }
}

// MARK: - NSURL

extension NSURL: URLStringConvertible {

  public var URLString: String {
    return absoluteString
  }
}
