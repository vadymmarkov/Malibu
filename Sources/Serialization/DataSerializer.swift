import Foundation

public final class DataSerializer: Serializing {
  public func serialize(response: Response) throws -> Data {
    if response.statusCode == 204 { return Data() }

    guard response.data.count > 0 else {
      throw NetworkError.noDataInResponse
    }

    return response.data
  }
}
