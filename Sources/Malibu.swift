import Foundation
import When

public enum Mode {
  case regular, partial, fake
}

// MARK: - Vars

public var mode: Mode = .regular
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

public func request(_ request: Request) -> Ride {
  return backfootSurfer.execute(request)
}
