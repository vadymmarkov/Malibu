import Foundation

public var parameterEncoders: [ContentType: ParameterEncoding] = [
  .JSON: JSONParameterEncoder(),
  .FormURLEncoded: FormURLEncoder()
]

var methodsWithEtags: [Method] = [.GET, .PATCH, .PUT]
