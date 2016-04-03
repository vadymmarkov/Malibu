import Foundation
import When

public enum Mode {
  case Regular, Partial, Fake
}

// MARK: - Helpers

var networkings = [String: Networking]()

// MARK: - Public

public var mode: Mode = .Regular
public var backfootSurfer = Networking()

public var parameterEncoders: [ContentType: ParameterEncoding] = [
  .JSON: JSONParameterEncoder(),
  .FormURLEncoded: FormURLEncoder()
]

// MARK: - Networkings

public func register(name: String, networking: Networking) {
  networkings[name] = networking
}

public func unregister(name: String) -> Bool {
  return networkings.removeValueForKey(name) != nil
}

public func networking(name: String) -> Networking {
  return networkings[name] ?? backfootSurfer
}

// MARK: - Mocks

public func register(mock mock: Mock) {
  backfootSurfer.register(mock: mock)
}

// MARK: - Requests

public func GET(request: GETRequestable) -> Promise<NetworkResult> {
  return backfootSurfer.GET(request)
}

public func POST(request: POSTRequestable) -> Promise<NetworkResult> {
  return backfootSurfer.POST(request)
}

public func PUT(request: PUTRequestable) -> Promise<NetworkResult> {
  return backfootSurfer.PUT(request)
}

public func PATCH(request: PATCHRequestable) -> Promise<NetworkResult> {
  return backfootSurfer.PATCH(request)
}

public func DELETE(request: DELETERequestable) -> Promise<NetworkResult> {
  return backfootSurfer.DELETE(request)
}

public func HEAD(request: HEADRequestable) -> Promise<NetworkResult> {
  return backfootSurfer.HEAD(request)
}
