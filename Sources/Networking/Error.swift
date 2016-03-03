import Foundation

public enum Error: ErrorType {
  case NoDataInResponse
  case NoResponseReceived
  case UnacceptableStatusCode(Int)
  case UnacceptableContentType(String)
  case MissingContentType
  
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
    }
    
    return NSLocalizedString(text, comment: "")
  }
}
