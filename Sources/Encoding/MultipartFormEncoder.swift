import Foundation
#if os(iOS) || os(watchOS) || os(tvOS)
  import MobileCoreServices
#elseif os(OSX)
  import CoreServices
#endif

public struct MultipartFormEncoder: ParameterEncoding {

  public func encode(parameters: [String: AnyObject]) throws -> NSData? {
    return try createBodyWithParameters(parameters, boundary: boundary)
  }

  func createBodyWithParameters(parameters: [String: AnyObject], boundary: String) throws -> NSData {
    var string = ""
    let components = QueryBuilder().buildComposents(parameters)

    for (key, value) in components {
      string += "--\(boundary)\r\n"
      string += "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
      string += "\(value)\r\n"
    }

    string += "--\(boundary)--\r\n"

    guard let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) else {
      throw Error.InvalidParameter
    }

    return data
  }
}
