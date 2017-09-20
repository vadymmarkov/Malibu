import Foundation

final class JsonEncoder: ParameterEncoding {
  func encode(parameters: [String: Any]) throws -> Data? {
    let data = try JSONSerialization.data(
      withJSONObject: parameters,
      options: JSONSerialization.WritingOptions())

    return data
  }
}
