import Foundation

public struct FormURLEncoder: ParameterEncoding {

  typealias Component = (String, String)

  let escapingCharacters = ":#[]@!$&'()*+,;="

  public func encode(parameters: [String: AnyObject]) throws -> NSData? {
    return queryString(parameters).dataUsingEncoding(NSUTF8StringEncoding,
      allowLossyConversion: false)
  }
}

// MARK: - Formatting

extension FormURLEncoder {

  func queryString(parameters: [String: AnyObject]) -> String {
    var components: [Component] = []

    parameters.forEach { key, value in
      components += queryComponents(key: key, value: value)
    }

    return components.map({ "\($0)=\($1)" }).joinWithSeparator("&")
  }

  func queryComponents(key key: String, value: AnyObject) -> [Component] {
    var components: [Component] = []

    if let dictionary = value as? [String: AnyObject] {
      dictionary.forEach { nestedKey, value in
        components += queryComponents(key: "\(key)[\(nestedKey)]", value: value)
      }
    } else if let array = value as? [AnyObject] {
      array.forEach { value in
        components += queryComponents(key: "\(key)[]", value: value)
      }
    } else {
      components.append((escape(key), escape("\(value)")))
    }

    return components
  }

  func escape(string: String) -> String {
    let allowedCharacters = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
    allowedCharacters.removeCharactersInString(escapingCharacters)

    var escapedString = ""

    if #available(iOS 8.3, OSX 10.10, *) {
      escapedString = string.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters) ?? string
    } else {
      var index = string.startIndex

      while index != string.endIndex {
        let endIndex = index.advancedBy(50, limit: string.endIndex)
        let range = Range(index..<endIndex)
        let substring = string.substringWithRange(range)

        index = endIndex
        escapedString += substring.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters)
          ?? substring
      }
    }

    return escapedString
  }
}
