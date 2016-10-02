import Foundation

struct MultipartFormEncoder: ParameterEncoding {

  // MARK: - ParameterEncoding

  func encode(_ parameters: [String: AnyObject]) throws -> Data? {
    let string = MultipartBuilder().buildMultipartString(parameters)

    guard let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true) else {
      throw NetworkError.invalidParameter
    }

    return data
  }
}
