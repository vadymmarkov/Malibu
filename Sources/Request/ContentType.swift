import Foundation

public enum ContentType {
  case Query
  case FormURLEncoded
  case JSON
  case MultipartFormData
  case Custom(String)

  enum Header: String {
    case JSON = "application/json"
    case FormURLEncoded = "application/x-www-form-urlencoded"
    case MultipartFormData = "multipart/form-data; boundary="
  }

  init(header: String?) {
    guard let header = header else {
      self = .Query
      return
    }

    let result: ContentType

    switch header {
    case Header.JSON.rawValue:
      result = .JSON
    case Header.FormURLEncoded.rawValue:
      result = .FormURLEncoded
    case "\(Header.MultipartFormData.rawValue)\(boundary)":
      result = .MultipartFormData
    default:
      result = .Custom(header)
    }

    self = result
  }

  var header: String? {
    let string: String?

    switch self {
    case .Query:
      string = nil
    case .JSON:
      string = Header.JSON.rawValue
    case .FormURLEncoded:
      string = Header.FormURLEncoded.rawValue
    case .MultipartFormData:
      string = Header.MultipartFormData.rawValue
    case .Custom(let value):
      string = value
    }

    return string
  }

  var encoder: ParameterEncoding? {
    var encoder: ParameterEncoding?

    switch self {
    case .JSON:
      encoder = JSONEncoder()
    case .FormURLEncoded:
      encoder = FormURLEncoder()
    case .MultipartFormData:
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
