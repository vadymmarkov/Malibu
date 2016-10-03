@testable import Malibu
import Quick
import Nimble

class HeaderSpec: QuickSpec {

  override func spec() {
    describe("Header") {

      describe(".acceptEncoding") {
        it("returns a correct value") {
          expect(Header.acceptEncoding).to(equal("gzip;q=1.0, compress;q=0.5"))
        }
      }

      describe(".acceptLanguage") {
        it("returns a correct value") {
          let expected = Locale.preferredLanguages.prefix(6).enumerated().map { index, languageCode in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(languageCode);q=\(quality)"
            }.joined(separator: ", ")

          expect(Header.acceptLanguage).to(equal(expected))
        }
      }

      describe(".userAgent") {
        it("returns a correct value") {
          var expected = "Malibu"

          if let info = Bundle.main.infoDictionary {
            let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
            let bundle = info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
            let version = info[kCFBundleVersionKey as String] as? String ?? "Unknown"
            let build = info[kCFBundleVersionKey as String] as? String ?? "Unknown"

            expected = "\(executable)/\(version) (\(bundle); build:\(build); \(Utils.osInfo)) \(Utils.frameworkInfo)"
          }

          expect(Header.userAgent).to(equal(expected))
        }
      }

      describe(".defaultHeaders") {
        it("returns a correct value") {
          let expected = [
            "Accept-Encoding": Header.acceptEncoding,
            "User-Agent": Header.userAgent
          ]

          expect(Header.defaultHeaders).to(equal(expected))
        }
      }

      describe(".authentication:username:password") {
        it("returns a correct value") {
          let username = "username"
          let password = "password"
          let credentialsData = "\(username):\(password)".data(using: String.Encoding.utf8)!
          let base64Credentials = credentialsData.base64EncodedString(options: [])
          let expected = "Basic \(base64Credentials)"

          expect(expected).to(equal(Header.authentication(username: username, password: password)))
        }
      }
    }
  }
}
