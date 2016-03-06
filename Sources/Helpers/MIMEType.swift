import Foundation

struct MIMEType {

  static func components(string: String) -> (type: String?, subtype: String?) {
    let trimmed = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    let splitted = trimmed.substringToIndex(trimmed.rangeOfString(";")?.startIndex ?? trimmed.endIndex)
    let array = splitted.componentsSeparatedByString("/")

    return (type: array.first, subtype: array.last)
  }

  let type: String
  let subtype: String

  // MARK: - Initialization

  init?(contentType: String) {
    let components = MIMEType.components(contentType)

    guard let type = components.type, subtype = components.subtype else {
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
