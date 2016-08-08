import Foundation

struct MultipartFormEncoder: ParameterEncoding {

  // MARK: - ParameterEncoding

  func encode(parameters: [String: AnyObject]) throws -> NSData? {
    let string = MultipartBuilder().buildMultipartString(parameters)

    guard let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) else {
      throw Error.InvalidParameter
    }

    return data
  }
}
