import Foundation

public final class StringSerializer: Serializing {
  let encoding: String.Encoding?

  public init(encoding: String.Encoding? = nil) {
    self.encoding = encoding
  }

  public func serialize(response: Response) throws -> String {
    if response.statusCode == 204 { return "" }

    let data = response.data

    guard data.count > 0 else {
      throw NetworkError.noDataInResponse
    }

    var stringEncoding: UInt

    if let encoding = encoding {
      stringEncoding = encoding.rawValue
    } else if let encodingName = response.httpUrlResponse.textEncodingName {
      stringEncoding = CFStringConvertEncodingToNSStringEncoding(
        CFStringConvertIANACharSetNameToEncoding(encodingName as CFString)
      )
    } else {
      stringEncoding = String.Encoding.isoLatin1.rawValue
    }

    guard let string = String(data: data, encoding: String.Encoding(rawValue: stringEncoding)) else {
      throw NetworkError.stringSerializationFailed(
        encoding: stringEncoding,
        response: response
      )
    }

    return string
  }
}
