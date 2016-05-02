import Foundation

struct QueryBuilder {

  typealias Component = (String, String)

  let escapingCharacters = ":#[]@!$&'()*+,;="

  func buildQuery(parameters: [String: AnyObject]) -> String {
    return buildComposents(parameters).map({ "\($0)=\($1)" }).joinWithSeparator("&")
  }

  func buildComposents(parameters: [String: AnyObject]) -> [Component] {
    var components: [Component] = []

    parameters.forEach { key, value in
      components += buildComponents(key: key, value: value)
    }

    return components
  }

  func buildComponents(key key: String, value: AnyObject) -> [Component] {
    var components: [Component] = []

    if let dictionary = value as? [String: AnyObject] {
      dictionary.forEach { nestedKey, value in
        components += buildComponents(key: "\(key)[\(nestedKey)]", value: value)
      }
    } else if let array = value as? [AnyObject] {
      array.forEach { value in
        components += buildComponents(key: "\(key)[]", value: value)
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
