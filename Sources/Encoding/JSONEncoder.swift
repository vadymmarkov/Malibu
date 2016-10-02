import Foundation

struct JSONEncoder: ParameterEncoding {

  func encode(_ parameters: [String: AnyObject]) throws -> Data? {
    let data = try JSONSerialization.data(withJSONObject: parameters,
      options: JSONSerialization.WritingOptions())

    return data
  }
}
