import Foundation
import When

// MARK: - Vars

public var parameterEncoders = [ContentType: ParameterEncoding]()
public let logger = Logger()
public let boundary = String(format: "Malibu%08x%08x", arc4random(), arc4random())

let backfootSurfer = Networking<AnyEndpoint>()

// MARK: - Storages

public func clearStorages() {
  EtagStorage().clear()
  RequestStorage.clearAll()
}

// MARK: - Requests

public func request(_ request: Request) -> NetworkPromise {
  return backfootSurfer.execute(request)
}
