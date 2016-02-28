import Foundation

var parameterEncoders: [ContentType: ParameterEncoding] = [
  .JSON: JSONParameterEncoder(),
  .FormURLEncoded: FormURLEncoder()
]
