import Foundation

struct JsonEncoder: ParameterEncoding {

  // MARK: - ParameterEncoding

  func encode(parameters: [String: Any]) throws -> Data? {
    let data = try JSONSerialization.data(
      withJSONObject: parameters,
      options: JSONSerialization.WritingOptions())

    return data
  }
}
