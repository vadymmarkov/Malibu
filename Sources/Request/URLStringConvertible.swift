import Foundation

public protocol URLStringConvertible {
  var URLString: String { get }
}

extension String: URLStringConvertible {

  public var URLString: String {
    return self
  }
}

extension NSURL: URLStringConvertible {

  public var URLString: String {
    return absoluteString
  }
}
