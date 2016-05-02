import Foundation

public enum ContentType {
  case Query
  case FormURLEncoded
  case JSON
  case MultipartFormData
  case Custom(String)

  var header: String? {
    let string: String?

    switch self {
    case .Query:
      string = nil
    case .JSON:
      string = "application/json"
    case .FormURLEncoded:
      string = "application/x-www-form-urlencoded"
    case .MultipartFormData:
      string = "multipart/form-data; boundary=MalibuBoundary-\(boundary)"
    case .Custom(let value):
      string = value
    }

    return string
  }

  var encoder: ParameterEncoding? {
    var encoder: ParameterEncoding?

    switch self {
    case .JSON:
      encoder = JSONParameterEncoder()
    case .FormURLEncoded:
      encoder = FormURLEncoder()
    case .MultipartFormData():
      encoder = MultipartFormEncoder()
    default:
      break
    }

    return encoder
  }
}

// MARK: - Hashable

extension ContentType: Hashable {

  public var hashValue: Int {
    let string = header ?? "query"
    return string.hashValue
  }
}

// MARK: - Equatable

public func ==(lhs: ContentType, rhs: ContentType) -> Bool {
  return lhs.hashValue == rhs.hashValue
}
