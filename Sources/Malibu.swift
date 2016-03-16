import Foundation

// MARK: - Helpers

var methodsWithEtags: [Method] = [.GET, .PATCH, .PUT]
var networkings = [String: Networking]()

// MARK: - Public

public var networking = Networking()

public var parameterEncoders: [ContentType: ParameterEncoding] = [
  .JSON: JSONParameterEncoder(),
  .FormURLEncoded: FormURLEncoder()
]

public func register(name: String, networking: Networking) {
  networkings[name] = networking
}

public func networkingNamed(name: String) -> Networking {
  return networkings[name] ?? networking
}


