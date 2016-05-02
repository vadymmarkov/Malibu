import Foundation
#if os(iOS) || os(watchOS) || os(tvOS)
  import MobileCoreServices
#elseif os(OSX)
  import CoreServices
#endif

public struct MultipartEncoder: ParameterEncoding {

  let boundary = NSUUID().UUIDString

  public func encode(parameters: [String: AnyObject]) throws -> NSData? {
    return try createBodyWithParameters(parameters, boundary: boundary)
  }

  func createBodyWithParameters(parameters: [String: AnyObject], boundary: String) throws -> NSData {
    let body = NSMutableData()
    let components = QueryBuilder().buildComposents(parameters)

    for (key, value) in components {
      try body.appendString("--\(boundary)\r\n")
      try body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
      try body.appendString("\(value)\r\n")
    }

//    for (key, path) in files {
//      let url = NSURL(fileURLWithPath: path)
//      let mimeType = try mimeTypeForPath(path)
//
//      guard let filename = url.lastPathComponent else {
//        throw Error.InvalidUploadFilePath
//      }
//
//      guard let data = NSData(contentsOfURL: url) else {
//        throw Error.InvalidParameter
//      }
//
//      try body.appendString("--\(boundary)\r\n")
//      try body.appendString("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\r\n")
//      try body.appendString("Content-Type: \(mimeType)\r\n\r\n")
//      body.appendData(data)
//      try body.appendString("\r\n")
//    }

    try body.appendString("--\(boundary)--\r\n")
    return body
  }

  func mimeTypeForPath(path: String) throws -> String {
    let url = NSURL(fileURLWithPath: path)

    guard let pathExtension = url.pathExtension else {
      throw Error.InvalidUploadFilePath
    }

    guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                          pathExtension as NSString,
                                                          nil)?.takeRetainedValue(),
      mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue()
      else { return "application/octet-stream" }

    return mimeType as String
  }
}

extension NSMutableData {

  func appendString(string: String) throws {
    guard let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) else {
      throw Error.InvalidParameter
    }

    appendData(data)
  }
}
