import Foundation

struct FormURLEncoder: ParameterEncoding {

  // MARK: - ParameterEncoding

  func encode(parameters: [String: Any]) throws -> Data? {
    return QueryBuilder()
      .buildQuery(from: parameters)
      .data(using: String.Encoding.utf8, allowLossyConversion: false)
  }
}
