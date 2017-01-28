public protocol Schema {

  var baseUrl: URLStringConvertible { get }
  var headers: [String: String] { get }
  var sessionConfiguration: SessionConfiguration { get }
}

