import Foundation
import When

// MARK: - Helpers

var methodsWithEtags: [Method] = [.GET, .PATCH, .PUT]
var networkings = [String: Networking]()

// MARK: - Public

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

public func networkingNamed(name: String) -> Networking {
  return networkings[name] ?? backfootSurfer
}

// MARK: - Requests

public func GET(request: Requestable) -> Promise<NetworkResult> {
  return backfootSurfer.GET(request)
}

public func POST(request: Requestable) -> Promise<NetworkResult> {
  return backfootSurfer.POST(request)
}

public func PUT(request: Requestable) -> Promise<NetworkResult> {
  return backfootSurfer.PUT(request)
}

public func PATCH(request: Requestable) -> Promise<NetworkResult> {
  return backfootSurfer.PATCH(request)
}

public func DELETE(request: Requestable) -> Promise<NetworkResult> {
  return backfootSurfer.DELETE(request)
}

public func HEAD(request: Requestable) -> Promise<NetworkResult> {
  return backfootSurfer.HEAD(request)
}
