import Foundation

public final class QueryBuilder {
  public typealias Component = (String, String)
  let escapingCharacters = ":#[]@!$&'()*+,;="

  public init() {}

  public func buildQuery(from parameters: [String: Any]) -> String {
    return buildComponents(from: parameters).map({ "\($0)=\($1)" }).joined(separator: "&")
  }

  public func buildComponents(from parameters: [String: Any]) -> [Component] {
    var components: [Component] = []

    for key in parameters.keys.sorted(by: <) {
      guard let value = parameters[key] else {
        continue
      }

      components += buildComponents(key: key, value: value)
    }

    return components
  }

  public func buildComponents(key: String, value: Any) -> [Component] {
    var components: [Component] = []

    if let dictionary = value as? [String: Any] {
      dictionary.forEach { nestedKey, value in
        components += buildComponents(key: "\(key)[\(nestedKey)]", value: value)
      }
    } else if let array = value as? [Any] {
      array.forEach { value in
        components += buildComponents(key: "\(key)[]", value: value)
      }
    } else if let bool = value as? Bool {
      components.append((escape(key), escape((bool ? "1" : "0"))))
    } else {
      components.append((escape(key), escape("\(value)")))
    }

    return components
  }

  public func escape(_ string: String) -> String {
    guard let allowedCharacters = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as? NSMutableCharacterSet else {
      return string
    }

    allowedCharacters.removeCharacters(in: escapingCharacters)

    var escapedString = ""

    if #available(iOS 8.3, *) {
      escapedString = string.addingPercentEncoding(
        withAllowedCharacters: allowedCharacters as CharacterSet) ?? string
    } else {
      var index = string.startIndex

      while index != string.endIndex {
        let endIndex = string.index(index, offsetBy: 50, limitedBy: string.endIndex) ?? string.endIndex
        let substring = string[index..<endIndex]

        escapedString += substring.addingPercentEncoding(
          withAllowedCharacters: allowedCharacters as CharacterSet) ?? String(substring)

        index = endIndex
      }
    }

    return escapedString
  }
}
