import Foundation

public struct JsonSerializer: Serializing {

  let options: JSONSerialization.ReadingOptions

  public init(options: JSONSerialization.ReadingOptions = .allowFragments) {
    self.options = options
  }

  public func serialize(data: Data, response: HTTPURLResponse) throws -> Any {
    if response.statusCode == 204 { return NSNull() }

    guard data.count > 0 else {
      throw NetworkError.noDataInResponse
    }

    do {
      return try JSONSerialization.jsonObject(with: data, options: options)
    } catch {
      throw error
    }
  }
}
