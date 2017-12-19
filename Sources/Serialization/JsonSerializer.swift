import Foundation

public final class JsonSerializer: Serializing {
  let options: JSONSerialization.ReadingOptions

  public init(options: JSONSerialization.ReadingOptions = .allowFragments) {
    self.options = options
  }

  public func serialize(response: Response) throws -> Any {
    if response.statusCode == 204 { return NSNull() }

    guard response.data.count > 0 else {
      throw NetworkError.noDataInResponse
    }

    do {
      return try JSONSerialization.jsonObject(with: response.data, options: options)
    } catch {
      throw error
    }
  }
}
