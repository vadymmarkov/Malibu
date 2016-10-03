import Foundation

public struct StringSerializer: Serializing {

  var encoding: String.Encoding?

  public init(encoding: String.Encoding? = nil) {
    self.encoding = encoding
  }

  public func serialize(data: Data, response: HTTPURLResponse) throws -> String {
    if response.statusCode == 204 { return "" }

    guard data.count > 0 else {
      throw NetworkError.noDataInResponse
    }

    var stringEncoding: UInt

    if let encoding = encoding {
      stringEncoding = encoding.rawValue
    } else if let encodingName = response.textEncodingName {
      stringEncoding = CFStringConvertEncodingToNSStringEncoding(
        CFStringConvertIANACharSetNameToEncoding(encodingName as CFString)
      )
    } else {
      stringEncoding = String.Encoding.isoLatin1.rawValue
    }

    guard let string = String(data: data, encoding: String.Encoding(rawValue: stringEncoding)) else {
      throw NetworkError.stringSerializationFailed(stringEncoding)
    }

    return string
  }
}
