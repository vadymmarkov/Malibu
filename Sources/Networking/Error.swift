import Foundation

public enum Error: ErrorType {
  case NoDataInResponse
  case NoResponseReceived
  case UnacceptableStatusCode(Int)
  case UnacceptableContentType(String)
  case MissingContentType
  case NoJSONArrayInResponseData
  case NoJSONDictionaryInResponseData

  var reason: String {
    var text: String

    switch self {
    case .NoDataInResponse:
      text = "No data in response"
    case .NoResponseReceived:
      text = "No response received"
    case .UnacceptableStatusCode(let statusCode):
      text = "Response status code \(statusCode) was unacceptable"
    case .UnacceptableContentType(let contentType):
      text = "Response content type \(contentType) was unacceptable"
    case .MissingContentType:
      text = "Response content type was missing"
    case .NoJSONArrayInResponseData:
      text = "No JSON array in response data"
    case .NoJSONDictionaryInResponseData:
      text = "No JSON dictionary in response data"
    }

    return NSLocalizedString(text, comment: "")
  }
}

// MARK: - Hashable

extension Error: Hashable {

  public var hashValue: Int {
    return reason.hashValue
  }
}

// MARK: - Equatable

public func ==(lhs: Error, rhs: Error) -> Bool {
  return lhs.reason == rhs.reason
}
