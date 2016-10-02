import Foundation

public struct DataSerializer: Serializing {

  public func serialize(_ data: Data, response: HTTPURLResponse) throws -> Data {
    if response.statusCode == 204 { return Data() }

    guard data.count > 0 else {
      throw NetworkError.noDataInResponse
    }

    return data
  }
}
