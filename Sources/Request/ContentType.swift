import Foundation

public enum ContentType {
  case query
  case formURLEncoded
  case json
  case multipartFormData
  case custom(String)

  enum Header: String {
    case json = "application/json"
    case formURLEncoded = "application/x-www-form-urlencoded"
    case multipartFormData = "multipart/form-data; boundary="
  }

  init(header: String?) {
    guard let header = header else {
      self = .query
      return
    }

    let result: ContentType

    switch header {
    case Header.json.rawValue:
      result = .json
    case Header.formURLEncoded.rawValue:
      result = .formURLEncoded
    case "\(Header.multipartFormData.rawValue)\(boundary)":
      result = .multipartFormData
    default:
      result = .custom(header)
    }

    self = result
  }

  var header: String? {
    let string: String?

    switch self {
    case .query:
      string = nil
    case .json:
      string = Header.json.rawValue
    case .formURLEncoded:
      string = Header.formURLEncoded.rawValue
    case .multipartFormData:
      string = "\(Header.multipartFormData.rawValue)\(boundary)"
    case .custom(let value):
      string = value
    }

    return string
  }

  var encoder: ParameterEncoding? {
    var encoder: ParameterEncoding?

    switch self {
    case .json:
      encoder = JsonEncoder()
    case .formURLEncoded:
      encoder = FormURLEncoder()
    case .multipartFormData:
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

public func == (lhs: ContentType, rhs: ContentType) -> Bool {
  return lhs.hashValue == rhs.hashValue
}
