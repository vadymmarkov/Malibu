import Foundation
import When

public enum Mode {
  case regular, partial, fake
}

// MARK: - Helpers

var networkings = [String: Networking]()

// MARK: - Vars

public var mode: Mode = .regular
public var backfootSurfer = Networking()
public var parameterEncoders = [ContentType: ParameterEncoding]()
public let logger = Logger()

public let boundary = String(format: "Malibu%08x%08x", arc4random(), arc4random())

// MARK: - Networkings

public func register(_ name: String, networking: Networking) {
  networking.requestStorage = RequestStorage(name: name)
  networkings[name] = networking
}

@discardableResult public func unregister(_ name: String) -> Bool {
  guard let networking = networkings.removeValue(forKey: name) else {
    return false
  }

  networking.requestStorage.clear()

  return true
}

public func networking(_ name: String) -> Networking {
  return networkings[name] ?? backfootSurfer
}

// MARK: - Storages

public func clearStorages() {
  EtagStorage().clear()
  RequestStorage.clearAll()
}

// MARK: - Mocks

public func register(mock: Mock) {
  backfootSurfer.register(mock: mock)
}

// MARK: - Requests

public func GET(_ request: GETRequestable) -> Ride {
  return backfootSurfer.GET(request)
}

public func POST(_ request: POSTRequestable) -> Ride {
  return backfootSurfer.POST(request)
}

public func PUT(_ request: PUTRequestable) -> Ride {
  return backfootSurfer.PUT(request)
}

public func PATCH(_ request: PATCHRequestable) -> Ride {
  return backfootSurfer.PATCH(request)
}

public func DELETE(_ request: DELETERequestable) -> Ride {
  return backfootSurfer.DELETE(request)
}

public func HEAD(_ request: HEADRequestable) -> Ride {
  return backfootSurfer.HEAD(request)
}
