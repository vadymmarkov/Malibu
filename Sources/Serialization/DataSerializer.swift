import Foundation

public final class DataSerializer: Serializing {
  public func serialize(data: Data, response: HTTPURLResponse) throws -> Data {
    if response.statusCode == 204 { return Data() }

    guard data.count > 0 else {
      throw NetworkError.noDataInResponse
    }

    return data
  }
}
