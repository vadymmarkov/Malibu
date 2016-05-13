import Foundation

struct FormURLEncoder: ParameterEncoding {

  func encode(parameters: [String: AnyObject]) throws -> NSData? {
    return QueryBuilder()
      .buildQuery(parameters)
      .dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
  }
}
