import Foundation

public enum Error: ErrorType {
  case NoDataInResponse
  case NoResponseReceived
  case StatusCodeValidationFailed(Int)
  
  var reason: String {
    var text: String
    
    switch self {
    case .NoDataInResponse:
      text = "No data in response"
    case .NoResponseReceived:
      text = "No response received"
    case .StatusCodeValidationFailed:
      text = "Response status code was unacceptable"
    }
    
    return NSLocalizedString(text, comment: "")
  }
}
