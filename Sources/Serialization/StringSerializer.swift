import Foundation

public struct StringSerializer: Serializing {

  var encoding: NSStringEncoding?

  public init(encoding: NSStringEncoding? = nil) {
    self.encoding = encoding
  }

  public func serialize(data: NSData, response: NSHTTPURLResponse) throws -> String {
    if response.statusCode == 204 { return "" }

    guard data.length > 0 else {
      throw Error.NoDataInResponse
    }

    var stringEncoding: UInt

    if let encoding = encoding {
      stringEncoding = encoding
    } else if let encodingName = response.textEncodingName {
      stringEncoding = CFStringConvertEncodingToNSStringEncoding(
        CFStringConvertIANACharSetNameToEncoding(encodingName)
      )
    } else {
      stringEncoding = NSISOLatin1StringEncoding
    }

    guard let string = String(data: data, encoding: stringEncoding) else {
      throw Error.StringSerializationFailed(stringEncoding)
    }

    return string
  }
}
