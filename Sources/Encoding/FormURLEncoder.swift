import Foundation

public struct FormURLEncoder: ParameterEncoding {

  public func encode(parameters: [String: AnyObject]) throws -> NSData? {
    return QueryBuilder()
      .buildQuery(parameters)
      .dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
  }
}
