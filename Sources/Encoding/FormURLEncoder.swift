import Foundation

public struct FormURLEncoder: ParameterEncoding {

  public func encode(parameters: [String: AnyObject]) throws -> NSData? {
    return QueryBuilder()
      .queryString(parameters)
      .dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
  }
}
