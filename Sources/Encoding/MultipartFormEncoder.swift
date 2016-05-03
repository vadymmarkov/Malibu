import Foundation

struct MultipartFormEncoder: ParameterEncoding {

  // MARK: - ParameterEncoding

  func encode(parameters: [String: AnyObject]) throws -> NSData? {
    let string = buildMultipartString(parameters, boundary: boundary)

    guard let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) else {
      throw Error.InvalidParameter
    }

    return data
  }

  // MARK: - Helpers

  func buildMultipartString(parameters: [String: AnyObject], boundary: String) -> String {
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
