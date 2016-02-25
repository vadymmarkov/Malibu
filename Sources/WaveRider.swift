import Foundation

struct WaveRider {
  
  static var parameterEncoders: [ContentType: ParameterEncoding] = [
    .JSON: JSONParameterEncoder(),
    .FormURLEncoded: FormURLEncoder()
  ]
}
