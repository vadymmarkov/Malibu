import Foundation

struct MIMEType {
  
  static func components(string: String) -> [String] {
    let trimmed = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    let splitted = trimmed.substringToIndex(trimmed.rangeOfString(";")?.startIndex ?? trimmed.endIndex)
    
    return splitted.componentsSeparatedByString("/")
  }
  
  let type: String
  let subtype: String
  
  // MARK: - Initialization
  
  init?(contentType: String) {
    let components = MIMEType.components(contentType)
    
    guard let type = components.first, subtype = components.last else {
      return nil
    }
    
    self.type = type
    self.subtype = subtype
  }
  
  func matches(MIME: MIMEType) -> Bool {
    var result: Bool
    
    switch (type, subtype) {
    case (MIME.type, MIME.subtype), (MIME.type, "*"), ("*", MIME.subtype), ("*", "*"):
      result = true
    default:
      result = false
    }
    
    return result
  }
}
