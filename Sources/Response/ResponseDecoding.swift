import Foundation
import When

// MARK: - Decoding

public extension Promise where T: Response {
  func decode<U: Decodable>(using type: U.Type, decoder: JSONDecoder) -> Promise<U> {
    return then { response -> U in
      guard !response.data.isEmpty else { throw NetworkError.noDataInResponse }

      do {
        return try decoder.decode(type, from: response.data)
      } catch {
        throw NetworkError.responseDecodingFailed(type: type, response: response)
      }
    }
  }
}
