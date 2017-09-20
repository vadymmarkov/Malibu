import Foundation

final class MultipartFormEncoder: ParameterEncoding {
  func encode(parameters: [String: Any]) throws -> Data? {
    let string = MultipartBuilder().buildMultipartString(from: parameters)

    guard let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true) else {
      throw NetworkError.invalidParameter
    }

    return data
  }
}
