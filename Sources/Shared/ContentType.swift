public enum ContentType {
  case JSON
  case FormURLEncoded
  case Custom(String)
  
  var value: String {
    let string: String
    
    switch self {
    case .JSON:
      string = "application/json"
    case .FormURLEncoded:
      string = "application/x-www-form-urlencoded"
    case .Custom(let value):
      string = value
    }
    
    return string
  }
}
