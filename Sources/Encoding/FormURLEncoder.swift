import Foundation

struct FormURLEncoder: ParameterEncoding {

  func encode(_ parameters: [String: AnyObject]) throws -> Data? {
    return QueryBuilder()
      .buildQuery(parameters)
      .data(using: String.Encoding.utf8, allowLossyConversion: false)
  }
}
