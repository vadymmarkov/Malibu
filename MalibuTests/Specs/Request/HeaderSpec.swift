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
            let executable: AnyObject = info[kCFBundleExecutableKey as String] ?? "Unknown"
            let bundle: AnyObject = info[kCFBundleIdentifierKey as String] ?? "Unknown"
            let version: AnyObject = info[kCFBundleVersionKey as String] ?? "Unknown"
            let os: AnyObject = Utils.osInfo
            let mutableUserAgent = NSMutableString(
              string: "\(executable)/\(bundle) (\(version); OS \(os))") as CFMutableString
            let transform = NSString(string: "Any-Latin; Latin-ASCII; [:^ASCII:] Remove") as CFString

            if CFStringTransform(mutableUserAgent, UnsafeMutablePointer<CFRange>(nil), transform, false) {
              expected = mutableUserAgent as String
            }
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
