import Foundation

public struct MultipartBuilder {

  public init() {}

  public func buildMultipartString(parameters: [String: AnyObject]) -> String {
    var string = ""
    let components = QueryBuilder().buildComponents(parameters: parameters)

    for (key, value) in components {
      string += "--\(boundary)\r\n"
      string += "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
      string += "\(value)\r\n"
    }

    string += "--\(boundary)--\r\n"

    return string
  }
}
